defmodule AshLotus.AshAdminCinderCompatibilityTest do
  use ExUnit.Case, async: true
  require Phoenix.LiveViewTest

  defmodule Note do
    use Ash.Resource,
      domain: AshLotus.AshAdminCinderCompatibilityTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshAdmin.Resource],
      validate_domain_inclusion?: false

    actions do
      defaults([:read, create: [:title]])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:title, :string, public?: true)
    end
  end

  defmodule Domain do
    use Ash.Domain, validate_config_inclusion?: false

    resources do
      resource(Note)
    end
  end

  test "AshAdmin renders its table against the pinned Cinder override" do
    html =
      Phoenix.LiveViewTest.render_component(&AshAdmin.Components.Resource.DataTable.render/1,
        resource: Note,
        domain: Domain,
        action: Ash.Resource.Info.action(Note, :read),
        authorizing: false,
        actor: nil,
        query: nil,
        ash_query: Ash.Query.for_read(Note, :read),
        params: %{},
        table: nil,
        tables: [],
        prefix: "/admin",
        tenant: nil,
        polymorphic_actions: [],
        has_filters: false,
        page_size: 25,
        pagination_mode: :offset,
        show_filters: false,
        myself: %Phoenix.LiveComponent.CID{cid: 1}
      )

    assert html =~ "table"
    assert html =~ "Title"
  end
end
