import Ecto.Query

alias Bizzer.{Repo, Adentry, Adimage}

for i <- 0..200 do
  IO.puts("Loop: #{i}")

  entries =
    from(r in Adentry,
      where: r.status != ^:accepted,
      limit: 10_000,
      order_by: [asc: :id],
      select: [:id, :image_ids]
    )
    |> Repo.all()

  entry_ids = entries |> Enum.map(& &1.id)
  image_ids = entries |> Enum.map(& &1.image_ids) |> List.flatten()

  images =
    from(r in Adimage,
      where: r.id in ^image_ids,
      where: not is_nil(r.public_url),
      select: [:public_url]
    )
    |> Repo.all()

  root = Path.join(__DIR__, "../../")
  IO.puts(root)

  # Delete images

  for img <- images do
    if img.public_url, do: File.rm(Path.join(root, img.public_url || "nofile"))
    # if img.static_url, do: File.rm(Path.join(root, img.static_url || "nofile"))
  end

  # clean adimage
  IO.inspect(Repo.delete_all(from(r in Adentry, where: r.id in ^entry_ids)))
  IO.inspect(Repo.delete_all(from(r in Adimage, where: r.id in ^image_ids)))
end
