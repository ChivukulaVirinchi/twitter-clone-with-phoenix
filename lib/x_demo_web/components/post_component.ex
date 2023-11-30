defmodule XDemoWeb.PostComponent do
  use XDemoWeb, :live_component
    alias XDemo.Timeline

  def render(assigns) do
    ~H"""
    <div class="p-4 space-x-2 border-b dark:border-bordercolor">
      <div class="flex space-x-4">
        <div>
          <div class="flex justify-between">
            <div>
              <h1 class="inline text-sm font-bold text-gray-800 cursor-pointer dark:text-text hover:underline">
                <%= get_name(@post.user.email) %>
              </h1>
              •
              <span class="text-sm text-gray-500 cursor-pointer dark:text-darktext2">
                <%= Timex.from_now(@post.inserted_at) %>
              </span>
            </div>
          </div>
          <p class="text-sm dark:text-text"><%= @post.body %></p>

          <img class="object-cover mt-2 border rounded-lg cursor-pointer" src={@post.photo_locations} />
        </div>
      </div>

      <div class="flex justify-around mt-2 text-gray-700 dark:text-darktext2">
        <div class="flex items-center space-x-1 cursor-pointer group">
          <button
            type="button"
            phx-target={@myself}
            phx-click="reposted"
            phx-value-post={@post.id}
            class="flex items-center select-none group group-hover:text-green-500"
          >
            <svg
              viewBox="0 0 24 24"
              class="w-4 h-4 mr-1 text-gray-400 group-hover:fill-current group-hover:text-green-500"
            >
              <g>
                <path d="M23.77 15.67c-.292-.293-.767-.293-1.06 0l-2.22 2.22V7.65c0-2.068-1.683-3.75-3.75-3.75h-5.85c-.414 0-.75.336-.75.75s.336.75.75.75h5.85c1.24 0 2.25 1.01 2.25 2.25v10.24l-2.22-2.22c-.293-.293-.768-.293-1.06 0s-.294.768 0 1.06l3.5 3.5c.145.147.337.22.53.22s.383-.072.53-.22l3.5-3.5c.294-.292.294-.767 0-1.06zm-10.66 3.28H7.26c-1.24 0-2.25-1.01-2.25-2.25V6.46l2.22 2.22c.148.147.34.22.532.22s.384-.073.53-.22c.293-.293.293-.768 0-1.06l-3.5-3.5c-.293-.294-.768-.294-1.06 0l-3.5 3.5c-.294.292-.294.767 0 1.06s.767.293 1.06 0l2.22-2.22V16.7c0 2.068 1.683 3.75 3.75 3.75h5.85c.414 0 .75-.336.75-.75s-.337-.75-.75-.75z">
                </path>
              </g>
            </svg>
            <%= @post.repost_count %>
          </button>
        </div>

        <div class="flex items-center space-x-1 cursor-pointer group">
          <button
            type="button"
            phx-target={@myself}
            phx-click="liked"
            phx-value-post={@post.id}
            class="flex items-center select-none group group-hover:text-pink-600"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="w-4 h-4 mr-1 text-gray-400 group-hover:fill-current group-hover:text-pink-600"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12z"
              />
            </svg>
            <%= @post.likes_count %>
          </button>
        </div>

        <div class="flex items-center justify-center w-8 h-8 rounded-full cursor-pointer hover:bg-hoverbg hover:text-primary">
          <svg viewBox="0 0 24 24" class="w-4 h-4 fill-current">
            <g>
              <path d="M12 22c-.414 0-.75-.336-.75-.75V2.75c0-.414.336-.75.75-.75s.75.336.75.75v18.5c0 .414-.336.75-.75.75zm5.14 0c-.415 0-.75-.336-.75-.75V7.89c0-.415.335-.75.75-.75s.75.335.75.75v13.36c0 .414-.337.75-.75.75zM6.86 22c-.413 0-.75-.336-.75-.75V10.973c0-.414.337-.75.75-.75s.75.336.75.75V21.25c0 .414-.335.75-.75.75z">
              </path>
            </g>
          </svg>
        </div>

        <div :if={@current_user == @post.user} class="flex items-center space-x-1 cursor-pointer group">
          <.link patch={~p"/posts/#{@post.id}/edit"}><svg class="w-5 h-5 text-gray-500 hover:text-primary" stroke-width="1.4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L10.582 16.07a4.5 4.5 0 01-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 011.13-1.897l8.932-8.931zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0115.75 21H5.25A2.25 2.25 0 013 18.75V8.25A2.25 2.25 0 015.25 6H10" />
            </svg></.link>
        </div>






      </div>
    </div>
    """
  end

  @spec handle_event(<<_::40, _::_*24>>, map(), any()) :: {:noreply, any()}
  def handle_event("liked", %{"post" => id}, socket) do
    post = Timeline.get_post!(id)
    Timeline.inc_likes(post)
    {:noreply, socket}
  end

  def handle_event("reposted", %{"post" => id}, socket) do
    post = Timeline.get_post!(id)
    Timeline.inc_reposts(post)
    {:noreply, socket}
  end

  def get_name(email) do
    [name | _] = String.split(email, "@")
    String.capitalize(name)
  end
end
