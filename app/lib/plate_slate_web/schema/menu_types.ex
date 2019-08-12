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
    field :priced_above, :float

    @desc "Priced below a value"
    field :priced_below, :float

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

    @desc "Name of the menu item."
    field :name, :string

    @desc "Description of the menu item."
    field :description, :string

    @desc "Price of the menu item."
    field :price, :float

    @desc "Date when the menu item was added."
    field :added_on, :date
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

  interface :search_result do
    field :name, :string

    resolve_type fn
      %PlateSlate.Menu.Item{}, _ ->  :menu_item
      %PlateSlate.Menu.Category{}, _ -> :category
      _, _ -> nil
    end
  end
end