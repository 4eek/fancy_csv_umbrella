defmodule Frontend.ImportPathTest do
  alias Frontend.ImportPath
  use ExUnit.Case

  test "resolves input and output paths" do
    {input_path, output_path} = ImportPath.resolve("/base", "foo.csv", fn -> "_suffix" end)

    assert "/base/files/tmp/foo_suffix.csv" == input_path
    assert "/base/files/foo_suffix.csv" == output_path
  end
end
