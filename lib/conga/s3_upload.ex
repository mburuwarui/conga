defmodule Conga.S3Upload do
  @moduledoc """
  Below is code from Chris McCord, modified for Cloudflare R2

  https://gist.github.com/chrismccord/37862f1f8b1f5148644b75d20d1cb073

  """
  @one_hour_seconds 3600

  @doc """
    Returns `{:ok, presigned_url}` where `presigned_url` is a url string

  """
  def presigned_put(config, opts) do
    key = Keyword.fetch!(opts, :key)
    expires_in = Keyword.get(opts, :expires_in, @one_hour_seconds)
    uri = "#{config.url}/#{URI.encode(key)}"

    url =
      :aws_signature.sign_v4_query_params(
        config.access_key_id,
        config.secret_access_key,
        config.region,
        "s3",
        :calendar.universal_time(),
        "PUT",
        uri,
        ttl: expires_in,
        uri_encode_path: false,
        body_digest: "UNSIGNED-PAYLOAD"
      )

    {:ok, url}
  end

  def presigned_get(config, opts) do
    key = Keyword.fetch!(opts, :key)
    expires_in = Keyword.get(opts, :expires_in, @one_hour_seconds)
    uri = "#{config.url}/#{URI.encode(key)}"

    url =
      :aws_signature.sign_v4_query_params(
        config.access_key_id,
        config.secret_access_key,
        config.region,
        "s3",
        :calendar.universal_time(),
        "GET",
        uri,
        ttl: expires_in,
        uri_encode_path: false
      )

    {:ok, url}
  end

  def presigned_delete(config, opts) do
    key = Keyword.fetch!(opts, :key)
    expires_in = Keyword.get(opts, :expires_in, @one_hour_seconds)
    uri = "#{config.url}/#{URI.encode(key)}"

    url =
      :aws_signature.sign_v4_query_params(
        config.access_key_id,
        config.secret_access_key,
        config.region,
        "s3",
        :calendar.universal_time(),
        "DELETE",
        uri,
        ttl: expires_in,
        uri_encode_path: false
      )

    {:ok, url}
  end
end
