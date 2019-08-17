defmodule PlateSlateWeb.Schema.Mutation.UpdateMenuTest do
  use PlateSlateWeb.ConnCase, async: true

  alias PlateSlate.{Repo, Menu}
  import Ecto.Query
  require IEx

  setup do
    PlateSlate.Seeds.run()
    category_id =
      from(t in Menu.Category, where: t.name == "Sandwiches")
      |> Repo.one!()
      |> Map.fetch!(:id)
      |> to_string
      %{category_id: category_id}
  end

  @update_query """
  mutation UpdateMenuItem($menuItem: MenuItemInput! $id: ID!) {
    response: updateMenuItem(id: $id input: $menuItem) {
      errors { key message }
      menuItem { id name description price }
    }
  }
  """

  @query """
  query ($id: ID) {
    menuItem(id: $id) { id name description price category_id }
  }
  """
  test "menuItem field returns a menu item", %{category_id: category_id} do
    query = "query { menuItems { id name } }"
    conn = get(build_conn(), "/api", query: query)
    assert %{"data" => %{"menuItems" => [first_menu_item | _menu_items]}} = json_response(conn, 200)

    updated_menu_item = %{
      "name" => "Foobar",
      "description" => "baz",
      "price" => "2.5",
      "category_id" => category_id
    }
    conn = build_conn()
    conn = post(conn, "/api", query: @update_query, variables: %{"menuItem" => updated_menu_item, "id" => first_menu_item["id"]})
    assert json_response(conn, 200)

    conn = get(build_conn(), "/api", query: @query, variables: %{id: first_menu_item["id"]})
    assert %{"data" => %{"menuItem" => menu_item}} = json_response(conn, 200)
    assert Map.put(updated_menu_item, "id", first_menu_item["id"]) == menu_item
  end
end
