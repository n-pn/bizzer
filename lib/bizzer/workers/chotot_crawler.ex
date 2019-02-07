defmodule Bizzer.ChototCrawler do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    if System.get_env("CRAWL") == "true" do
      IO.puts("Crawling chotot")
      fetch_list()
    end

    {:ok, state}
  end

  def handle_info(:crawling, state) do
    fetch_list()

    {:noreply, state}
  end

  @gateway "https://gateway.chotot.com/v1/public/ad-listing"

  def fetch_list(page \\ 1, entry_added \\ 0, image_added \\ 0) do
    url = "#{@gateway}?page=#{page}&o=#{(page - 1) * 20}"

    data = fetch_json(url, %{"ads" => []})
    list = for item <- data["ads"] || [], do: item["list_id"]
    crawled = crawled_entries(list)
    list = list -- crawled

    fetch_item(list, page, entry_added, image_added)
  end

  defp crawled_entries(list) do
    list = Enum.map(list, &Integer.to_string/1)
    import Ecto.Query

    from(
      r in Bizzer.Adentry,
      where: r.origin_uid in ^list,
      where: r.origin_src == 1,
      select: [:origin_uid]
    )
    |> Bizzer.Repo.all()
    |> Enum.map(&String.to_integer(&1.origin_uid))
  end

  @max_page 5
  @interval 1000 * 60 * 30

  def fetch_item([], page, entry_added, image_added) do
    if page < @max_page do
      fetch_list(page + 1, entry_added, image_added)
    else
      if entry_added > 0 do
        Bizzer.NotificationAction.notify_admin(%{
          type: :import_adentry,
          data: %{
            source: "Chợ Tốt",
            entry_count: entry_added,
            image_count: image_added
          }
        })
      else
        IO.puts("Error: No new entries")
      end

      Process.send_after(self(), :crawling, @interval)
    end
  end

  def fetch_item([idct | list], page, entry_added, image_added) do
    url = "#{@gateway}/#{idct}"

    case fetch_json(url) do
      nil ->
        fetch_item(list, page, entry_added, image_added)

      %{"message" => "Không tìm thấy dữ liệu."} ->
        fetch_item(list, page, entry_added, image_added)

      data ->
        try do
          res =
            data
            |> fill_user
            |> fill_shop
            |> fill_locations
            |> fill_groupings
            |> fill_props
            |> create_adentry

          case res do
            {:ok, adentry} ->
              IO.puts("Entry [#{adentry.slug}] added.")
              image_count = length(adentry.image_ids)
              fetch_item(list, page, entry_added + 1, image_added + image_count)

            {:error, changeset} ->
              IO.inspect(changeset.errors)
              fetch_item(list, page, entry_added, image_added)
          end
        rescue
          e ->
            IO.inspect(e)
            fetch_item(list, page, entry_added, image_added)
        end
    end
  end

  defp fill_user(inp) do
    uid = inp["ad"]["account_oid"]

    user_id =
      case Bizzer.UserQuery.find_origin(uid, 1) do
        nil -> create_user(uid)
        user -> user.id
      end

    out = %{"user_id" => user_id}
    {inp, out}
  end

  @user_api "https://gateway.chotot.com/v1/public/profile/"
  @password Pbkdf2.hash_pwd_salt("chotot123")

  defp create_user(uid) do
    data = fetch_json(@user_api <> uid)

    time =
      if time = data["create_time"],
        do: Bizzer.TimeUtil.from_unix(time, :second),
        else: NaiveDateTime.utc_now()

    item = %{
      phone: data["phone"],
      crypted_password: @password,
      name: data["full_name"],
      email: data["email"],
      address: data["address"],
      avatar_url: store_image(data["avatar"]),
      inserted_at: time,
      origin_uid: data["account_oid"],
      origin_src: :chotot
    }

    case Bizzer.UserAction.insert(item, :import) do
      {:ok, user} -> user.id
      {:error, _} -> 1
    end
  end

  defp fill_shop({inp, out}) do
    if shop = inp["ad"]["shop"] do
      slug = if urls = shop["urls"], do: Enum.at(urls, 0)["url"], else: shop["alias"]

      shop_id =
        case Bizzer.ShopQuery.find(slug) do
          nil -> create_shop(slug, shop, out["user_id"], inp["ad"]["phone"])
          shop -> shop.id
        end

      out = Map.put(out, "shop_id", shop_id)
      {inp, out}
    else
      {inp, out}
    end
  end

  defp create_shop(slug, shop, user_id, user_phone) do
    shop = %{
      origin_src: :chotot,
      origin_uid: slug,
      user_id: user_id,
      phone: user_phone,
      slug: slug,
      name: shop["name"],
      address: shop["address"],
      avatar_url: store_image(shop["profileImageUrl"]),
      inserted_at: shop["createdDate"]
    }

    case Bizzer.ShopAction.insert(shop, :import) do
      {:ok, shop} -> shop.id
      {:error, _} -> nil
    end
  end

  @locations Path.join(__DIR__, "mappers/chotot_locations.json")
             |> File.read!()
             |> Poison.decode!()

  defp fill_locations({inp, out}) do
    case @locations[inp["ad"]["area"] |> Integer.to_string()] do
      nil -> {inp, out}
      slug -> {inp, Map.put(out, "location_slug", slug)}
    end
  end

  defp fill_groupings({inp, out}) do
    case map_grouping(inp) do
      nil -> {inp, out}
      slug -> {inp, Map.put(out, "grouping_slug", slug)}
    end
  end

  @propkeys Path.join(__DIR__, "mappers/chotot_propkeys.json")
            |> File.read!()
            |> Poison.decode!()

  @propvals Path.join(__DIR__, "mappers/chotot_propvals.json")
            |> File.read!()
            |> Poison.decode!()

  @unneed [
    "area",
    "region",
    "address",
    "size",
    "block",
    "balconydirection",
    "floornumber",
    "floors",
    "toilets",
    "birthday"
  ]

  defp fill_props({inp, out}) do
    subject = inp["ad"]["subject"] |> String.downcase() |> Bizzer.FormatUtil.remove_accent()

    extra =
      case inp["ad"]["category"] do
        3050 ->
          %{"the-loai" => "dong-ho"}

        3060 ->
          %{"the-loai" => "giay-dep"}

        3070 ->
          %{"the-loai" => "tui-xach"}

        3080 ->
          %{"the-loai" => "nuoc-hoa"}

        3090 ->
          %{"the-loai" => "trang-suc"}

        4010 ->
          %{
            "the-loai" =>
              cond do
                similar(subject, ["game", "ps", "nds", "3ds", "xbox"]) -> "game"
                true -> "cac-loai-khac"
              end
          }

        4040 ->
          %{
            "the-loai" =>
              cond do
                similar(subject, ["phim"]) -> "phim"
                similar(subject, ["sach"]) -> "sach"
                similar(subject, ["truyen"]) -> "truyen"
                true -> "cac-loai-khac"
              end
          }

        5020 ->
          %{
            "the-loai" =>
              cond do
                similar(subject, ["tv", "ti vi"]) -> "tivi"
                similar(subject, ["loa"]) -> "loa"
                similar(subject, ["amply"]) -> "amply"
                true -> "cac-loai-khac"
              end
          }

        5050 ->
          %{
            "the-loai" =>
              cond do
                similar(subject, ["may anh", "camera"]) -> "may-anh"
                similar(subject, ["quay phim"]) -> "may-quay-phim"
                similar(subject, ["may chieu"]) -> "may-chieu-phim"
                true -> "cac-loai-khac"
              end
          }

        5060 ->
          %{
            "the-loai" =>
              cond do
                similar(subject, ["man hinh", "monitor"]) -> "man-hinh-may-tinh"
                true -> "phu-kien-may0tin"
              end
          }

        8010 ->
          %{"the-loai" => "do-dung-van-phong"}

        8030 ->
          %{"the-loai" => "do-chuyen-dung"}

        9030 ->
          %{
            "the-loai" =>
              cond do
                similar(subject, ["tu lanh"]) -> "tu-lanh"
                similar(subject, ["dieu hoa"]) -> "dieu-hoa"
                similar(subject, ["may giat"]) -> "may-giat"
                similar(subject, ["quat dien"]) -> "quat-dien"
                similar(subject, ["den dien"]) -> "den-dien"
                similar(subject, ["bep dien"]) -> "bep-dien"
                similar(subject, ["noi com"]) -> "noi-com-dien"
                true -> "thiet-bi-khac"
              end
          }

        12010 ->
          %{"the-loai" => "ga"}

        12020 ->
          %{"the-loai" => "cho"}

        12030 ->
          %{"the-loai" => "chim"}

        12040 ->
          %{"the-loai" => "phu-kien"}

        _ ->
          %{}
      end

    keys = inp["ad_params"] |> Map.keys() |> Enum.reject(&(&1 in @unneed))

    attrs =
      for key <- keys do
        val = inp["ad"][key]
        param = @propkeys[key]
        value = @propvals["#{key}|#{val}"]
        {param, value}
      end
      |> Enum.reject(&(elem(&1, 0) == nil))
      |> Enum.into(%{})

    attrs = Map.merge(attrs, extra)
    out = Map.put(out, "props", attrs)

    {inp, out}
  end

  @groupings Path.join(__DIR__, "mappers/chotot_groupings.json")
             |> File.read!()
             |> Poison.decode!()

  @services ["dich-vu-gia-dinh-van-phong", "dich-vu-sua-chua-bao-duong"]
  @utensils ["giuong-tu-ban-ghe", "thiet-bi-phong-bep-ve-sinh", "ngoai-that-cay-canh-ca-canh"]

  defp map_grouping(inp) do
    idct = Integer.to_string(inp["ad"]["category"])
    subject = inp["ad"]["subject"] |> String.downcase() |> Bizzer.FormatUtil.remove_accent()

    case idct do
      "1010" ->
        if map_user_need(inp["ad"]["type"]) == :"can-mua",
          do: "thue-can-ho-chung-cu",
          else: "mua-ban-can-ho-chung-cu"

      "1020" ->
        if map_user_need(inp["ad"]["type"]) == :"can-mua",
          do: "thue-nha-rieng-biet-thu",
          else: "mua-ban-nha-rieng-biet-thu"

      "1030" ->
        if map_user_need(inp["ad"]["type"]) == :"can-mua",
          do: "thue-van-phong-cua-hang",
          else: "mua-ban-van-phong-cua-hang"

      "1040" ->
        if inp["ad"]["type"] in ["s", "k"],
          do: "mua-ban-dat-nen-du-an",
          else: "thue-cac-loai-nha-dat-khac"

      "1050" ->
        if inp["ad"]["type"] in ["s", "k"],
          do: "mua-ban-cac-loai-nha-dat-khac",
          else: "thue-phong-tro-o-ghep"

      "3050" ->
        "dong-ho-trang-suc"

      "3060" ->
        "giay-dep-tui-xach"

      "3070" ->
        "giay-dep-tui-xach"

      "3080" ->
        "nuoc-hoa-my-pham"

      "3090" ->
        "dong-ho-trang-suc"

      "4010" ->
        "do-suu-tam-phim-sach-game"

      "5020" ->
        "mua-ban-do-dien-tu-khac"

      "5050" ->
        "mua-ban-do-dien-tu-khac"

      "5060" ->
        "mua-ban-do-dien-tu-khac"

      "6020" ->
        cond do
          similar(subject, ["van phong", "gia dinh", "bao ve", "giup viec"]) ->
            "dich-vu-gia-dinh-van-phong"

          similar(subject, ["sua chua", "bao duong"]) ->
            "dich-vu-sua-chua-bao-duong"

          true ->
            Enum.random(@services)
        end

      "8010" ->
        "do-van-phong-do-chuyen-dung"

      "8030" ->
        "do-van-phong-do-chuyen-dung"

      "9030" ->
        "do-dien-gia-dung"

      "9040" ->
        cond do
          similar(subject, ["giuong", "tu", "ban", "ghe"]) ->
            "giuong-tu-ban-ghe"

          similar(subject, ["xoong", "noi", "chao", "bat", "dua", "toilet", "voi", "chau"]) ->
            "thiet-bi-phong-bep-ve-sinh"

          similar(subject, ["cay canh", "ca canh", "cong", "khoa"]) ->
            "ngoai-that-cay-canh-ca-canh"

          true ->
            Enum.random(@utensils)
        end

      "12010" ->
        "thu-nuoi-phu-kien-thu-nuoi"

      "12020" ->
        "thu-nuoi-phu-kien-thu-nuoi"

      "12030" ->
        "thu-nuoi-phu-kien-thu-nuoi"

      "12040" ->
        "thu-nuoi-phu-kien-thu-nuoi"

      "13010" ->
        if inp["ad"]["contract_type"] == 1,
          do: "viec-lam-toan-thoi-gian",
          else: "viec-lam-ban-thoi-gian"

      idct ->
        @groupings[idct]
    end
  end

  defp create_adentry({inp, out}) do
    time = inp["ad"]["list_time"] |> Bizzer.TimeUtil.from_unix(:millisecond)

    item = %{
      "status" => :locked,
      "origin_src" => :chotot,
      "origin_uid" => inp["ad"]["list_id"] |> Integer.to_string(),
      "subject" => inp["ad"]["subject"],
      "image_urls" => inp["ad"]["images"],
      "details" => inp["ad"]["body"] || "",
      "inserted_at" => time,
      "updated_at" => time,
      "price" => inp["ad"]["price"] || 0,
      "price_print" => inp["ad"]["price_string"] || "0 đ",
      "payment" => inp["ad"]["payment"],
      "user_need" => map_user_need(inp["ad"]["type"]),
      "user_type" => map_user_type(inp["ad"]["company_ad"])
    }

    item = Map.merge(item, out)

    Bizzer.AdentryAction.insert(item, :import)
  end

  defp map_user_need("k"), do: :"can-mua"
  defp map_user_need("h"), do: :"can-mua"
  defp map_user_need(_), do: :"can-ban"

  defp map_user_type(true), do: :"ban-chuyen"
  defp map_user_type(_), do: :"ca-nhan"

  defp fetch_json(url, fallback \\ nil) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body}} ->
        Poison.decode!(body)

      {:error, reason} ->
        IO.inspect(reason)
        fallback
    end
  end

  defp store_image(nil), do: nil

  defp store_image(url) do
    case Bizzer.ImageUtil.fetch(url, "avatars") do
      {:ok, url} -> url
      {:error, _} -> nil
    end
  end

  defp similar(input, matches) do
    Enum.find(matches, fn match -> input =~ match end) != nil
  end
end
