defmodule Bizzer.NotificationQuery do
  use Bizzer, :repo
  alias Bizzer.Notification

  def fetch(user_id) do
    from(
      r in Notification,
      where: r.user_id == ^user_id,
      where: r.read == false,
      order_by: [desc: :id],
      limit: 20
    )
    |> Repo.all()
  end
end
