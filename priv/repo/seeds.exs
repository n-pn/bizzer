# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bizzer.Repo.insert!(%Bizzer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Bizzer.{
  UserAction,
  LocationAction,
  GroupingAction,
  GroupingQuery,
  PropkeyAction,
  PropkeyQuery,
  PropvalAction,
  PropvalQuery
}

inp_path = fn file -> Path.join([__DIR__, "bootstraps", file]) end
load_json_file = fn file -> File.read!(file) |> Poison.decode!() end

for user <- load_json_file.(inp_path.("users.json")),
    do: {:ok, _} = UserAction.insert(user, :manual)

for file <- Path.wildcard(inp_path.("locations/*.json")) do
  location = load_json_file.(file)
  location = location |> Map.put("type", :parent)
  {:ok, parent} = LocationAction.create(location)

  for child <- location["children"] do
    child = Map.merge(child, %{"type" => :child, "parent_id" => parent.id})
    {:ok, _} = LocationAction.create(child)
  end
end

groupings =
  for file <- Path.wildcard(inp_path.("groupings/*.json")) do
    grouping = load_json_file.(file)
    grouping = grouping |> Map.put("type", :parent)
    {:ok, parent} = GroupingAction.create(grouping)

    childs =
      for child <- grouping["children"] do
        child = Map.merge(child, %{"type" => :child, "parent_id" => parent.id})
        {:ok, child} = GroupingAction.create(child)
        {child.slug, child.id}
      end

    [{parent.slug, parent.id}] ++ childs
  end

groupings = groupings |> List.flatten() |> Enum.into(%{})

for file <- Path.wildcard(inp_path.("properties/**/*.json")) do
  propkey = load_json_file.(file)

  grouping_id = groupings[propkey["grouping_slug"]]
  propkey = propkey |> Map.put("grouping_id", grouping_id)

  propkey = propkey |> Map.put("type", :parent)
  {:ok, param} = PropkeyAction.create(propkey)

  for propval <- propkey["propvals"] do
    propval = Map.merge(propval, %{"type" => :parent, "propkey_id" => param.id})
    {:ok, _} = PropvalAction.create(propval)
  end
end

for file <- Path.wildcard(inp_path.("properties/**/*.json")) do
  propkey = load_json_file.(file)

  if parent_slug = propkey["parent_slug"] do
    grouping = GroupingQuery.find(propkey["grouping_slug"])
    param = PropkeyQuery.find(grouping.id, propkey["slug"])
    parent_param = PropkeyQuery.find(grouping.id, parent_slug)
    PropkeyAction.update(param, %{parent_id: parent_param.id})

    for propval <- propkey["propvals"] do
      value = PropvalQuery.find(param.id, propval["slug"])
      parent_slug = propval["parent_slug"]
      parent_value = PropvalQuery.find(parent_param.id, parent_slug)
      PropvalAction.update(value, %{parent_id: parent_value.id})
    end
  end
end
