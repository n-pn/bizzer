defmodule Bizzer.AdentryAction do
  use Bizzer, :repo
  alias Bizzer.Adentry

  @types [:seed, :import, :manual]
  def insert(attrs, type \\ :manual) do
    %Adentry{}
    |> Adentry.changeset(attrs, type)
    |> Repo.insert()
  end

  @types [:update, :review]
  def update(%Adentry{} = adentry, attrs, type \\ :update) when type in @types do
    adentry
    |> Adentry.changeset(attrs, type)
    |> Repo.update()
  end

  def delete(%Adentry{} = adentry) do
    adentry
    |> change
    |> Ecto.Changeset.put_change(:status, :deleted)
    |> Repo.update()
  end

  def change(params, adentry \\ %Adentry{}) do
    Adentry.changeset(adentry, params, :change)
  end

  @doc "Mark chotot imported adentry ad accepted if there is no image need to be watermarked"
  def unlock(adimage) do
    adentries = Repo.all(from(r in Adentry, where: fragment("image_ids @> ?", ^[adimage.id])))

    for adentry <- adentries do
      adimages = Bizzer.AdimageQuery.glob(adentry.image_ids)
      unedited = adimages |> Enum.find(&(&1.status == :unedit))

      if unedited == nil do
        image_ids = adimages |> Enum.map(& &1.id)
        image_urls = adimages |> Enum.map(& &1.public_url)

        Repo.update_all(
          from(r in Adentry, where: r.id == ^adentry.id),
          set: [
            editor_id: 1,
            status: :accepted,
            image_ids: image_ids,
            image_urls: image_urls,
            updated_at: NaiveDateTime.utc_now()
          ]
        )

        :ok
      end
    end
  end
end
