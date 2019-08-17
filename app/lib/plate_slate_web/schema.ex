#---
# Excerpted from "Craft GraphQL APIs in Elixir with Absinthe",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wwgraphql for more book information.
#---
defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  alias PlateSlateWeb.Resolvers

  import_types __MODULE__.MenuTypes

  query do
    import_fields :menu_query
    import_fields :menu_queries

    field :search, list_of(:search_result) do
      arg :matching, non_null(:string)
      resolve &Resolvers.Menu.search/3
    end
  end

  mutation do
    field :create_menu_item, :menu_item_result do
      arg :input, non_null(:menu_item_input)
      resolve &Resolvers.Menu.create_menu_item/3
    end
    field :update_menu_item, :menu_item_result do
      arg :id, :id
      arg :input, non_null(:menu_item_input)
      resolve &Resolvers.Menu.update_menu_item/3
    end
  end

  object :menu_queries do
    @desc "List of available items on the menu."
    field :menu_items, list_of(:menu_item) do
      arg :filter, :menu_item_filter
      arg :order, type: :sort_order, default_value: :asc
      resolve &Resolvers.Menu.menu_items/3
    end
  end

  object :menu_query do
    @desc "Returns a menu item with the given id."
    field :menu_item, :menu_item do
      arg :id, :id
      resolve &Resolvers.Menu.menu_item/3
    end
  end

  enum :sort_order do
    value :asc
    value :desc
  end
end
