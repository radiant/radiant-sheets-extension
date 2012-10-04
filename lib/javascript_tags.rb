module JavascriptTags
  include Radiant::Taggable
  class TagError < StandardError; end
  
  desc %{
Renders the content from or a reference to the javascript specified in the @slug@ 
attribute. Additionally, the @as@ attribute can be used to make the tag render 
as one of the following:

* with no @as@ value the javascript's content is rendered by default.
* @inline@ - wraps the javascript's content in an (X)HTML @<script>@ element.
* @path@ - the full path to the javascript.
* @link@ - embeds the url in an (X)HTML @<script>@ element (creating a link to the external javascript).

*Additional Options:*
When rendering @as="inline"@ or @as="link"@, the (X)HTML @type@ attribute
is automatically be set to the default javascript content-type.
You can overrride this attribute or add additional ones by passing extra
attributes to the @<r:javascript>@ tag.
      
*Usage:*
      
<pre><code><r:javascript slug="site.css" as="inline" 
  type="text/custom" id="my_id" />
<r:javascript slug="other.js" as="link" /></code></pre>

The above example will produce the following:
      
<pre><code>        <script type="text/custom" id="my_id">
//<![CDATA[
  var your_script = 'this content';
//]]>
</script>
<script type="text/javascript" src="/js/other.js"></script></code></pre>
  }
  tag 'javascript' do |tag|
    slug = (tag.attr['slug'] || tag.attr['name'])
    raise TagError.new("`javascript' tag must contain a `slug' attribute.") unless slug
    if (javascript = JavascriptPage.find_by_slug(slug))
      mime_type = tag.attr['type'] || javascript.headers['Content-Type']
      path = javascript.path
      optional_attributes = tag.attr.except('slug', 'name', 'as', 'type').inject('') { |s, (k, v)| s << %{#{k}="#{v}" } }.strip
      optional_attributes = " #{optional_attributes}" unless optional_attributes.empty?
      case tag.attr['as']
      when 'url','path'
        path
      when 'inline'
        %{<script type="#{mime_type}"#{optional_attributes}>\n//<![CDATA[\n#{javascript.render_part('body')}\n//]]>\n</script>}
      when 'link'
        asset_host = (Radiant::Config['sheets.asset_host'] ? Radiant::Config['sheets.asset_host'] : '')
        %{<script type="#{mime_type}" src="#{asset_host}#{path}"#{optional_attributes}></script>}
      else
        javascript.render_part('body')
      end
    else
      raise TagError.new("javascript #{slug} not found")
    end
  end
end
