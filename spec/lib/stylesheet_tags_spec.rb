# require 'spec_helper'
require File.expand_path("../../spec_helper", __FILE__)

describe "Stylesheet Tags" do
  dataset :stylesheets

  let(:page){ pages(:home) }

  describe "<r:stylesheet>" do
    before do
      Radiant::Config['sheets.use_cache_param?'] = true
    end
    let(:site_css){pages(:site_css)}
    subject { page }
    it { should render(%{<r:stylesheet />}).with_error("`stylesheet' tag must contain a `slug' attribute.") }
    it { should render(%{<r:stylesheet slug="bogus" />}).with_error("stylesheet bogus not found") }
    it { should render(%{<r:stylesheet slug="site.css" />}).as("p { color: blue; }") }
    it { should render(%{<r:stylesheet slug="site.css" as="url" />}).as("/css/site.css?#{site_css.digest}") }
    it { should render(%{<r:stylesheet slug="site.css" as="link" />}).as(%{<link rel="stylesheet" type="text/css" href="/css/site.css?#{site_css.digest}" />}) }
    it { 
      Radiant::Config['sheets.asset_host'] = "http://asset-host.com"
      should render(%{<r:stylesheet slug="site.css" as="link" />}).as(%{<link rel="stylesheet" type="text/css" href="http://asset-host.com/css/site.css?#{site_css.digest}" />}) 
    }
    it { should render(%{<r:stylesheet slug="site.css" as="link" type="special/type" />}).as(%{<link rel="stylesheet" type="special/type" href="/css/site.css?#{site_css.digest}" />}) }
    it { should render(%{<r:stylesheet slug="site.css" as="link" something="custom" />}).as(%{<link rel="stylesheet" type="text/css" href="/css/site.css?#{site_css.digest}" something="custom" />}) }
    it { should render(%{<r:stylesheet slug="site.css" as="link" rel="alternate" />}).as(%{<link rel="alternate" type="text/css" href="/css/site.css?#{site_css.digest}" />}) }
    it { should render(%{<r:stylesheet slug="site.css" as="inline" />}).as(%{<style type="text/css">
/*<![CDATA[*/
p { color: blue; }
/*]]>*/
</style>}) }
    it { should render(%{<r:stylesheet slug="site.css" as="inline" type="special/type" />}).as(%{<style type="special/type">
/*<![CDATA[*/
p { color: blue; }
/*]]>*/
</style>}) }
    it { should render(%{<r:stylesheet slug="site.css" as="inline" something="custom" />}).as(%{<style type="text/css" something="custom">
/*<![CDATA[*/
p { color: blue; }
/*]]>*/
</style>}) }
    it "should apply text filters when outputing content" do
      css_result_from_sass = Sass::Engine.new(pages(:sassy_sass).part('body').content, Compass.sass_engine_options || {}).render
      site_css.should render(%{<r:stylesheet slug="sassy.sass" />}).as(css_result_from_sass)
    end
  end

end
