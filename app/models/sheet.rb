require 'digest/md5'
module Sheet
  module InvalidHomePage; end
  module Instance
    def self.included(base)
      base.class_eval {
        before_validation :set_title
        before_validation :set_breadcrumb
        before_validation :set_published
        class_inheritable_accessor :sheet_root
        
        def self.root
          Page.root.children.first(:conditions => {:class_name => self.to_s})
        rescue NoMethodError => e
          e.extend Sheet::InvalidHomePage
          raise e
        end

        def self.create_root
          s = self.new_with_defaults
          s.parent_id = Page.root.id
          s.created_by_id = ''
          s.slug = self.name == 'StylesheetPage' ? 'css' : 'js'
          s.save
        end

        def self.default_page_parts
          PagePart.new(:name => 'body')
        end
        
        def self.create_from_upload!(file)
          @sheet = self.new_with_defaults
          @sheet.upload = file
          @sheet.save!
          @sheet
        end
        
      }
    end
    
    def cache?
      true
    end
  
    # so that it is ignored when finding children in radius tags
    def virtual?
      true
    end
  
    def layout
      nil
    end
    
    def find_by_path(path, live = true, clean = true)
      path = clean_path(path) if clean
      my_path = self.path
      if (my_path == path) && (not live or published?)
        self
      elsif (path =~ /^#{Regexp.quote(my_path)}([^\/]*)/)
        slug_child = children.find_by_slug($1)
        if slug_child
          return slug_child
        else
          super
        end
      end
    end
    def find_by_url(*args)
      ActiveSupport::Deprecation.warn("`find_by_url' has been deprecated; use `find_by_path' instead.", caller)
      find_by_path(*args)
    end
        
    def upload=(file)
      case
      when file.blank?
        self.errors.add(:upload, 'not given. Please upload a file.')
      when !file.kind_of?(ActionController::UploadedFile)
        self.errors.add(:upload, 'is an unusable format.')
      else
        self.slug = file.original_filename.to_slug().gsub(/-css$/,'.css').gsub(/-js/,'.js')
        self.part('body').content = file.read
      end
    end

    def digest
      @generated_digest ||= digest!
    end

    def digest!
      Digest::MD5.hexdigest(self.render)
    end

    def child_path(child)
      clean_path(path + '/' + child.slug + child.cache_marker)
    end
    
    def cache_marker
      Radiant::Config['sheets.use_cache_param?'] ? "?#{digest}" : ''
    end
  
    private

    def clean_path(path)
      "/#{ path.to_s.strip }".gsub(%r{//+}, '/')
    end
  
    def set_title
      self.title = self.slug
    end
  
    def set_breadcrumb
      self.breadcrumb = self.slug
    end
    
    def set_published
      self.published_at = Time.zone.now
      self.status_id = Status[:published].id
    end
  end
end
