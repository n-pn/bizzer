defmodule Bizzer.NotificationAction do
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

  def insert(data) do
    %Notification{}
    |> Notification.changeset(data, :create)
    |> Repo.insert()
  end

  def notify_admin(data) do
    admins = Repo.all(from(r in Bizzer.User, where: r.role == ^:admin))

    for admin <- admins do
      %Notification{user_id: admin.id}
      |> Notification.changeset(data, :create)
      |> Repo.insert()
    end
  end
end
