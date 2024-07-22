# frozen_string_literal: true

require "test_helper"

class ServiceWorker::RouteTest < Minitest::Test
  def test_initialize_route
    route = new_route("/path", foo: "bar")

    assert_equal "/path", route.path_pattern
    assert_equal({foo: "bar"}, route.options)
  end

  def test_initialize_route_with_asset
    route = new_route("/path", "asset", foo: "bar")

    assert_equal "/path", route.path_pattern
    assert_equal "asset", route.asset_pattern
    assert_equal({foo: "bar"}, route.options)
  end

  def test_match
    match "/*", "foo", "/", "foo"
    match "/*", "%<paths>s", "/", ""
    match "/*", "foo", "/foo", "foo"
    match "/*", "%<paths>s", "/foo", "foo"
    match "/*", "foo", "/foo/bar/baz", "foo"
    match "/*", "%<paths>s", "/foo/bar/baz", "foo/bar/baz"
    match "/*/foobar.js", "foobar.js", "/not/found/foo/bar.js", nil
    match "/*/foobar.js", "foobar.js", "/is/found/foobar.js", "foobar.js"

    match "/*stuff", "foo", "/", "foo"
    match "/*stuff", "%<stuff>s/foo", "/", "foo"
    match "/*stuff", "%<stuff>s/bar", "/foo", "foo/bar"
    match "/*stuff", "%<stuff>s/bar", "/foo/", "foo/bar"
    match "/*stuff", "%<stuff>s/boo", "/foo/bar/baz", "foo/bar/baz/boo"

    match "/foo/*", "%<paths>s", "/foo", ""
    match "/foo/*", "%<paths>s", "/foo/bar", "bar"
    match "/foo/*", "%<paths>s", "/foo/bar/baz", "bar/baz"
    match "/foo/*stuff", "%<stuff>s", "/", nil
    match "/foo/*stuff", "%<stuff>s", "/foo", ""
    match "/foo/*stuff", "%<stuff>s", "/foo/bar/baz", "bar/baz"
    match "/", "", "/", ""
    match "/", "", "/foo", nil
    match "/foo", "", "/", nil
    match "/foo", "", "/foo", ""
    match "/:id", nil, "/42", ":id"
    match "/:id", nil, "/", nil
    match "/posts/:id", "%<id>s", "/posts/42", "42"
    match "/posts/:id", "%<id>s", "/posts", nil
    match "/:x/:y", "%<x>s/%<y>s", "/a/b", "a/b"
    match "/posts/:id", "%<id>s.js", "/posts/42.js", "42.js"
    match "/api/v:version", "%<version>s", "/api/v2", "2"
    match "/api/v:version/things", "%<version>s", "/api/v2/things", "2"
  end

  def test_match_route_pack_true
    ServiceWorker::Handlers.stub(:webpacker?, true) do
      route = new_route("foo", "bar", pack: true)

      assert_equal "bar", route.match("foo").to_s
    end
  end

  def test_match_route_pack_asset_name
    ServiceWorker::Handlers.stub(:webpacker?, true) do
      route = new_route("foo", pack: "bar")

      assert_equal "bar", route.match("foo").to_s
    end
  end

  def match(path_pattern, asset_pattern, path_name, asset_name)
    msg = "#{caller(1..1).first} expected route #{path_pattern} to "

    route = new_route(path_pattern, asset_pattern)

    if asset_name
      msg += "match #{path_name} and return #{asset_name}"
      assert_equal(asset_name, route.match(path_name).to_s, msg)
    else
      msg += "no match #{path_name}"
      assert_nil(route.match(path_name), msg)
    end
  end

  def new_route(*args)
    ServiceWorker::Route.new(*args)
  end
end
