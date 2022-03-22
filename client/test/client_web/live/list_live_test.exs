defmodule ClientWeb.ListLiveTest do
  use ClientWeb.ConnCase

  import Phoenix.LiveViewTest
  import Client.ListsFixtures

  @create_attrs %{list_name: "some list_name", user_id: 42}
  @update_attrs %{list_name: "some updated list_name", user_id: 43}
  @invalid_attrs %{list_name: nil, user_id: nil}

  defp create_list(_) do
    list = list_fixture()
    %{list: list}
  end

  describe "Index" do
    setup [:create_list]

    test "lists all lists", %{conn: conn, list: list} do
      {:ok, _index_live, html} = live(conn, Routes.list_index_path(conn, :index))

      assert html =~ "Listing Lists"
      assert html =~ list.list_name
    end

    test "saves new list", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.list_index_path(conn, :index))

      assert index_live |> element("a", "New List") |> render_click() =~
               "New List"

      assert_patch(index_live, Routes.list_index_path(conn, :new))

      assert index_live
             |> form("#list-form", list: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#list-form", list: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.list_index_path(conn, :index))

      assert html =~ "List created successfully"
      assert html =~ "some list_name"
    end

    test "updates list in listing", %{conn: conn, list: list} do
      {:ok, index_live, _html} = live(conn, Routes.list_index_path(conn, :index))

      assert index_live |> element("#list-#{list.id} a", "Edit") |> render_click() =~
               "Edit List"

      assert_patch(index_live, Routes.list_index_path(conn, :edit, list))

      assert index_live
             |> form("#list-form", list: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#list-form", list: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.list_index_path(conn, :index))

      assert html =~ "List updated successfully"
      assert html =~ "some updated list_name"
    end

    test "deletes list in listing", %{conn: conn, list: list} do
      {:ok, index_live, _html} = live(conn, Routes.list_index_path(conn, :index))

      assert index_live |> element("#list-#{list.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#list-#{list.id}")
    end
  end

  describe "Show" do
    setup [:create_list]

    test "displays list", %{conn: conn, list: list} do
      {:ok, _show_live, html} = live(conn, Routes.list_show_path(conn, :show, list))

      assert html =~ "Show List"
      assert html =~ list.list_name
    end

    test "updates list within modal", %{conn: conn, list: list} do
      {:ok, show_live, _html} = live(conn, Routes.list_show_path(conn, :show, list))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit List"

      assert_patch(show_live, Routes.list_show_path(conn, :edit, list))

      assert show_live
             |> form("#list-form", list: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#list-form", list: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.list_show_path(conn, :show, list))

      assert html =~ "List updated successfully"
      assert html =~ "some updated list_name"
    end
  end
end
