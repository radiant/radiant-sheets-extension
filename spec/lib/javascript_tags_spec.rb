# require 'spec_helper'
require File.expand_path("../../spec_helper", __FILE__)

describe "Javascript Tags" do
  dataset :javascripts

  let(:page){ pages(:home) }
    let(:javascript_page){ pages(:site_js)}

  describe "<r:javascript>" do
    before do
      Radiant::Config['sheets.use_cache_param?'] = true
    end
    subject { page }
    it { should render(%{<r:javascript />}).with_error("`javascript' tag must contain a `slug' attribute.") }
    it { should render(%{<r:javascript slug="bogus" />}).with_error("javascript bogus not found") }
    it { should render(%{<r:javascript slug="site.js" />}).as('alert("site!");') }
    it { should render(%{<r:javascript slug="site.js" as="url" />}).as("/js/site.js?#{javascript_page.digest}") }
    it { should render(%{<r:javascript slug="site.js" as="link" />}).as(%{<script type="#{javascript_page.headers['Content-Type']}" src="#{javascript_page.path}"></script>}) }
    it { 
      Radiant::Config['sheets.asset_host'] = "http://asset-host.com"
      should render(%{<r:javascript slug="site.js" as="link" />}).as(%{<script type="#{javascript_page.headers['Content-Type']}" src="http://asset-host.com#{javascript_page.path}"></script>}) 
    }
    it { should render(%{<r:javascript slug="site.js" as="link" type="special/type" />}).as(%{<script type="special/type" src="#{javascript_page.path}"></script>}) }
    it { should render(%{<r:javascript slug="site.js" as="link" something="custom" />}).as(%{<script type="#{javascript_page.headers['Content-Type']}" src="#{javascript_page.path}" something="custom"></script>}) }
    it { should render(%{<r:javascript slug="site.js" as="inline" />}).as(%{<script type="#{javascript_page.headers['Content-Type']}">
//<![CDATA[
alert("site!");
//]]>
</script>}) }
    it { should render(%{<r:javascript slug="site.js" as="inline" type="special/type" />}).as(%{<script type="special/type">
//<![CDATA[
alert("site!");
//]]>
</script>}) }
    it { should render(%{<r:javascript slug="site.js" as="inline" something="custom" />}).as(%{<script type="#{javascript_page.headers['Content-Type']}" something="custom">
//<![CDATA[
alert("site!");
//]]>
</script>}) }
  end

end
