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
  import_types __MODULE__.OrderingTypes

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
    field :place_order, :order_result do
      arg :input, non_null(:place_order_input)
      resolve &Resolvers.Ordering.place_order/3
    end
    field :ready_order, :order_result do
      arg :id, non_null(:id)
      resolve &Resolvers.Ordering.ready_order/3
    end
    field :complete_order, :order_result do
      arg :id, non_null(:id)
      resolve &Resolvers.Ordering.complete_order/3
    end
  end

  subscription do
    field :new_order, :order do
      config fn _args, _info ->
        {:ok, topic: "*"}
      end
      trigger :place_order, topic: fn
      _ -> ["*"]
      end
    end
    field :update_order, :order do
      arg :id, non_null(:id)
      config fn args, _info ->
        {:ok, topic: args.id}
      end
      trigger [:ready_order, :complete_order], topic: fn
        %{order: order} -> [order.id]
        _ ->  []
      end
      resolve fn %{order: order}, _, _ ->
        {:ok, order}
      end
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
