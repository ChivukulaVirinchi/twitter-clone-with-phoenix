defmodule XDemoWeb.ErrorJSONTest do
  use XDemoWeb.ConnCase, async: true

  test "renders 404" do
    assert XDemoWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert XDemoWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
