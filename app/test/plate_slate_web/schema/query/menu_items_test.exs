defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  @query """
  {
    menuItems {
      name
    }
  }
  """
  test "menuItems field returns menu items" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query)

    assert %{"data" => %{"menuItems" => menu_items}} = json_response(conn, 200)
    assert Enum.all?([
        %{"name" => "Reuben"},
        %{"name" => "Croque Monsieur"},
        %{"name" => "Muffuletta"},
    ], fn item -> item in menu_items end)
  end

  @query """
  query validQuery($term:String!) {
    menuItems(matching: $term) {
      name
    }
  }
  """
  @variables %{"term" => "reu"}
  test "menuItems field returns menu items filtered by name" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query, variables: @variables)

    assert %{"data" => %{"menuItems" => menu_items}} = json_response(conn, 200)
    assert [%{"name" => "Reuben"}] = menu_items
  end

  @query """
  query invalidQuery($term: String!) {
    menuItems(matching: $term) {
      name
    }
  }
  """
  @variables %{"term" => 123}
  test "menuItems field returns errors when using a bad value" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query, variables: @variables)

    assert %{"errors" => [%{"message" => message}]} = json_response(conn, 400)
    assert ~s{Argument "matching" has invalid value $term.} = message
  end
end