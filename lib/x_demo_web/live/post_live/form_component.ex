defmodule XDemoWeb.PostLive.FormComponent do
  use XDemoWeb, :live_component

  alias XDemo.Timeline

  @impl true
  def mount(socket) do
    socket =
      allow_upload(socket, :photos,
        accept: ~w(.png .jpg .jpeg),
        max_entries: 1,
        max_file_size: 10_000_000
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage post records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:body]} type="text" label="Body" />
        <div>
            Add up to <%= @uploads.photos.max_entries %> photos
            (max <%= trunc(@uploads.photos.max_file_size / 1_000_000) %> MB each )
          </div>

          <div class="border-2 border-gray-400 border-dashed" phx-drop-target={@uploads.photos.ref}>
            <.live_file_input upload={@uploads.photos} /> or drag and drop here
          </div>

          <.error :for={err <- upload_errors(@uploads.photos)}>
            <%= Phoenix.Naming.humanize(err) %>
          </.error>

          <div :for={entry <- @uploads.photos.entries} class="entry">
            <.live_img_preview entry={entry} />

            <div>
              <div><%= entry.progress %>%</div>
              <div>
                <span style={"width: #{entry.progress}%; background-color: #19bff0;"}></span>
              </div>
              <.error :for={err <- upload_errors(@uploads.photos, entry)}>
                <%= Phoenix.Naming.humanize(err) %>
              </.error>
            </div>
            <a  href="#" phx-click="cancel" phx-value-ref={entry.ref}> &times; </a>
          </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Timeline.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Timeline.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  defp save_post(socket, :edit, post_params) do
    case Timeline.update_post(socket.assigns.post, post_params) do
      {:ok, _post} ->

        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_post(socket, :new, post_params) do
      photo_locations =
        consume_uploaded_entries(socket, :photos, fn meta, entry ->
          dest = Path.join(["priv", "static", "uploads", "#{entry.uuid}-#{entry.client_name}"])

          File.cp!(meta.path, dest)
          url_path = static_path(socket, "/uploads/#{Path.basename(dest)}")
          {:ok, url_path}
        end)

      post_params = Map.put(post_params, "photo_locations", photo_locations)

    case Timeline.create_post(socket.assigns.current_user, post_params) do
      {:ok, _post} ->


        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

end
