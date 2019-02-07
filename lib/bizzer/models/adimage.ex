defmodule Bizzer.Adimage do
  use Bizzer, :schema

  schema "adimages" do
    field :status, Bizzer.AdimageStatus, default: :unedit
    belongs_to :worker, Bizzer.User

    field :static_url, :string
    field :public_url, :string

    field :x_offset, :integer, virtual: true
    field :y_offset, :integer, virtual: true

    field :origin_src, Bizzer.OriginType, default: :bizzer
    field :origin_url, :string

    timestamps()
  end

  @doc false
  def changeset(model, attrs, :manual) do
    model
    |> cast(attrs, [:origin_url])
    |> put_change(:origin_src, :bizzer)
    |> unique_constraint(:origin_url)
    |> store_image
  end

  def changeset(model, attrs, :import) do
    model
    |> cast(attrs, [:origin_url, :origin_src])
    |> unique_constraint(:origin_url)
    |> cache_image
  end

  def changeset(model, attrs, :precache) do
    model
    |> cast(attrs, [:static_url])
  end

  def changeset(model, attrs, :watermark) do
    model
    |> cast(attrs, [:worker_id, :x_offset, :y_offset])
    |> validate_required([:worker_id, :x_offset, :y_offset])
    |> insert_watermark
  end

  defp store_image(chset) do
    origin_url = chset |> get_change(:origin_url)
    {:ok, static_url} = Bizzer.ImageUtil.store(origin_url)
    {:ok, public_url} = Bizzer.ImageUtil.auto_watermark(static_url)

    chset
    |> put_change(:static_url, static_url)
    |> put_change(:public_url, public_url)
    |> put_change(:status, :unneed)
    |> unique_constraint(:public_url)
  end

  defp cache_image(chset) do
    origin_src = chset |> get_field(:origin_src)
    origin_url = chset |> get_field(:origin_url)

    case Bizzer.ImageUtil.fetch(origin_url) do
      {:ok, static_url} ->
        if origin_src == :chotot do
          chset
          |> put_change(:static_url, static_url)
          |> put_change(:status, :unedit)
        else
          {:ok, public_url} = Bizzer.ImageUtil.auto_watermark(static_url)

          chset
          |> put_change(:static_url, static_url)
          |> put_change(:public_url, public_url)
          |> put_change(:status, :unneed)
          |> unique_constraint(:public_url)
        end

      {:error, _} ->
        chset |> add_error(:origin_url, "Unknown error")
    end
  end

  defp insert_watermark(%{valid?: true} = chset) do
    x_offset = chset |> get_change(:x_offset)
    y_offset = chset |> get_change(:y_offset)
    static_url = chset |> get_field(:static_url)
    {:ok, public_url} = Bizzer.ImageUtil.watermark(static_url, x_offset, y_offset)

    chset
    |> put_change(:public_url, public_url)
    |> put_change(:status, :edited)
  end

  defp insert_watermark(chset), do: chset
end
