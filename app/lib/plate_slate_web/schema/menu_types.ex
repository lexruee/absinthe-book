defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation

  alias PlateSlateWeb.Resolvers

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    @desc "Matching a name"
    field :name, :string

    @desc "Matching a category name"
    field :category, :string

    @desc "Matching a tag"
    field :tag, :string

    @desc "Priced above a value"
    field :priced_above, :decimal

    @desc "Priced below a value"
    field :priced_below, :decimal

    @desc "Added to the menu before this date"
    field :added_before, :date

    @desc "Added to the menu after this date"
    field :added_after, :date
  end

  @desc "A menu item."
  object :menu_item do
    interfaces [:search_result]

    @desc "Id of the menu item."
    field :id, :id

    @desc "Category Id"
    field :category_id, :id

    @desc "Name of the menu item."
    field :name, :string

    @desc "Description of the menu item."
    field :description, :string

    @desc "Price of the menu item."
    field :price, :decimal

    @desc "Date when the menu item was added."
    field :added_on, :date
  end

  @desc "A menu item result."
  object :menu_item_result do
    field :menu_item, :menu_item
    field :errors, list_of(:input_error)
  end

  @desc "An error encountered trying to persist input"
  object :input_error do
    field :key, non_null(:string)
    field :message, non_null(:string)
  end

  @desc "A category."
  object :category do
    interfaces [:search_result]

    @desc "Category name"
    field :name, :string

    @desc "Category description"
    field :description, :string

    @desc "Category items"
    field :items, list_of(:menu_item) do
      resolve &Resolvers.Menu.items_for_category/3
    end
  end

  @desc "Menu Item input data"
  input_object :menu_item_input do
    @desc "Name"
    field :name, non_null(:string)

    @desc "Description"
    field :description, :string

    @desc "Price"
    field :price, non_null(:decimal)

    @desc "Category Id"
    field :category_id, non_null(:id)
  end

  @desc "A search result."
  interface :search_result do
    field :name, :string

    resolve_type fn
      %PlateSlate.Menu.Item{}, _ ->  :menu_item
      %PlateSlate.Menu.Category{}, _ -> :category
      _, _ -> nil
    end
  end

  scalar :decimal do
    parse fn
      %{value: value}, _ when is_binary(value) -> Decimal.parse(value)
      %{value: value}, _ when is_float(value) -> Decimal.parse(value |> Float.to_string)
      %{value: value}, _ when is_integer(value) -> Decimal.parse(value |> Integer.to_string)
      _, _ -> :error
    end

    serialize &to_string/1
  end

  scalar :date do
    parse fn input ->
      with %Absinthe.Blueprint.Input.String{value: value} <- input,
           {:ok, date} <- Date.from_iso8601(input.value) do
        {:ok, date}
      else
        _ -> :error
      end
    end

    serialize fn date ->
      Date.to_iso8601(date)
    end
  end
end