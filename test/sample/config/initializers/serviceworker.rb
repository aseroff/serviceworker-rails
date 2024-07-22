# frozen_string_literal: true

Sample::Application.configure do
  config.serviceworker.routes.draw_default

  config.serviceworker.routes.draw do
    match "/header-serviceworker.js" => "another/serviceworker.js",
      :headers => {"X-Resource-Header" => "A resource"}

    match "/nested/serviceworker.js", asset: "another/serviceworker.js"

    match "/captures/*named/serviceworker.js" => "captures/%{named}-serviceworker.js"

    get "/*/serviceworker.js" => "fallback/serviceworker.js"

    get "/webpack-serviceworker.js", pack: "serviceworker.js"
  end
end
