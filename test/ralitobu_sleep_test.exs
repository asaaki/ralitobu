defmodule RalitobuSleepTest do
  use ExUnit.Case

  test "test basic" do
    {res, _, _, _, _, _, _} = Ralitobu.checkout("my-bucket", 3, 10_000)
    assert res == :ok
  end

  test "ralitobu test with sleep" do
    # run 100 checkout
    _res = for _i <- 1..100 do
      Ralitobu.checkout("bucket-test-spawn", 10_000, 750)
    end

    # Sleep for 0.5 second, could also use (Process.sleep(500))
    :timer.sleep(500)

    # inspect the bucket
    {_res, count, count_remaining, _, _, _, _} = Ralitobu.inspect("bucket-test-spawn", 10_000, 750)

    assert count == 100
    assert count_remaining == 9900
  end

end

