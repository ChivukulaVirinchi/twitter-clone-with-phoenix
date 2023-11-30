defmodule XDemoWeb.PostLive.Index do
  use XDemoWeb, :live_view

  alias XDemo.Timeline
  alias XDemo.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    {:ok, stream(socket, :posts, Timeline.list_posts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Timeline.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({XDemoWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post, at: 0)}
  end

  def handle_info({:post_updated, post}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  def handle_info({:post_created, post}, socket) do
    {:noreply, stream_insert(socket, :posts, post, at: 0)}
  end

  def handle_info({:post_deleted, post}, socket) do
    {:noreply, stream_delete(socket, :posts, post)}
  end
end
