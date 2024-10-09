defmodule Conga.DoubleWriter do
  @behaviour Phoenix.LiveView.UploadWriter

  @impl true
  def init(_opts) do
    file_name = ".jpg"

    with {:ok, path} <- Plug.Upload.random_file("local_file"),
         {:ok, _file} <- File.open(path, [:binary, :write]),
         s3_op <- ExAws.S3.initiate_multipart_upload("bucket", file_name) do
      {:ok,
       %{
         path: path,
         key: file_name,
         chunk: 1,
         s3_op: s3_op,
         s3_config: ExAws.Config.new(s3_op.service)
       }}
    end
  end

  @impl true
  def meta(state) do
    %{local_path: state.path, key: state.key}
  end

  @impl true
  def write_chunk(data, state) do
    case IO.binwrite(state.file, data) do
      :ok ->
        part = ExAws.S3.Upload.upload_chunk!({data, state.chunk}, state.s3_op, state.s3_config)
        {:ok, %{state | chunk: state.chunk + 1, parts: [part | state.parts]}}

      {:error, reason} ->
        {:error, reason, state}
    end
  end

  @impl true
  def close(state, _reason) do
    case {File.close(state.file),
          ExAws.S3.Upload.complete(state.parts, state.s3_op, state.s3_config)} do
      {:ok, {:ok, _}} ->
        {:ok, state}

      {{:error, reason}, _} ->
        {:error, reason}

      {_, {:error, reason}} ->
        {:error, reason}
    end
  end
end
