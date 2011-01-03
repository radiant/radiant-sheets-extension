# Uncomment this if you reference any of your controllers in activate
require_dependency 'application_controller'

class SheetsExtension < Radiant::Extension
  version "1.0"
  description "Manage CSS and Javascript content in Radiant CMS as Sheets, a subset of Pages"
  url "http://github.com/radiant/radiant"
  
  cattr_accessor :stylesheet_filters
  cattr_accessor :javascript_filters
  
  @@stylesheet_filters ||= []
  @@stylesheet_filters << SassFilter
  @@javascript_filters ||= []
  
  def activate
    SassFilter
    
    tab 'Design' do
      add_item "Stylesheets", "/admin/styles", :before => "Snippets"
      add_item "Javascripts", "/admin/scripts", :before => "Snippets"
    end
    
    ApplicationHelper.module_eval do
      def filter_options_for_select_with_sheet_restrictions(selected=nil)
        sheet_filters = SheetsExtension.stylesheet_filters + SheetsExtension.javascript_filters
        filters = TextFilter.descendants - sheet_filters
        options_for_select([[t('select.none'), '']] + filters.map { |s| s.filter_name }.sort, selected)
      end
      alias_method_chain :filter_options_for_select, :sheet_restrictions
    end
    
    Page.class_eval do
      def sheet?
        false
      end

      include JavascriptTags
      include StylesheetTags
    end
    
    Admin::NodeHelper.module_eval do
      def render_node_with_sheets(page, locals = {})
        unless page.sheet?
          render_node_without_sheets(page, locals)
        end
      end
      alias_method_chain :render_node, :sheets
    end
    
    SiteController.class_eval do
      cattr_writer :sheet_cache_timeout
  
      def self.sheet_cache_timeout
        @@sheet_cache_timeout ||= 30.days
      end
      
      def set_cache_control_with_sheets
        if @page.sheet?
          expires_in self.class.sheet_cache_timeout, :public => true, :private => false
        else
          set_cache_control_without_sheets
        end
      end
      alias_method_chain :set_cache_control, :sheets
    end
    
  end
end
