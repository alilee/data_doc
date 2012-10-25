require 'builder'

module DataDoc
  
  #
  # Presents the results of a query in an html table.
  #
  class Present
    
    #
    # Accept display options from a block. Returns html table.
    #
    #   present 'select one, two from relation' do
    #     caption 'Table caption'
    #     column_order 'two', 'one'
    #   end
    #
    # For more table configuration options see the member functions
    # of DataDoc::Present
    #
    def self.present(doc, arel_or_str, &blk)
      rows = doc.connection.select_all(arel_or_str)
      p = Present.new(doc, rows)
      p.instance_eval(&blk) unless blk.nil?
      p.render
    end
    
    #
    # Defines presentation set and order of columns.
    #
    # Not every field queried needs to be presented.
    #
    #   present 'select one, two from relation' do 
    #     column_order 'two', 'one'
    #   end
    #
    def column_order(*order)
      @column_order = order
    end
    
    #
    # Set the caption for the table
    #
    #   present 'select 1' do 
    #     caption 'Table caption'
    #   end
    #
    def caption(text)
      @caption = text
    end
    
    #
    # Rename the column heading text for a particular column.
    #
    #   present 'select one, two from relation' do 
    #     label 'one', 'New column heading'
    #   end
    #
    def label(column, text)
      @labels[column] = text
    end
    
    #
    # Define a block which is called to override the contents of
    # a cell.
    #
    # Return nil to revert to the default behaviour.
    #
    #   present 'select one, two from relation' do 
    #     each_cell 'one' do |col, row|
    #       row[col] == 'true' ? 'Short' : 'Long'
    #     end
    #   end
    #
    def each_cell(col, &blk) # :yields: col, row
      @each_cell[col] = blk
    end
    
    #
    # Define a calculated column based on a block.
    #
    #   present 'select one, two from relation' do 
    #     calculated 'three' do |col, row|
    #       row['two'] == 'true' ? 'Short' : 'Long'
    #     end
    #   end
    #
    def calculated(col, &blk) # :yields: row
      @calculated[col] = blk
    end
    
    #
    # Suppress header row.
    #
    #   present 'select one, two from relation' do 
    #     no_headers
    #   end
    #
    def no_headers
      @no_headers = true
    end    
    
    #
    # Generate html.
    #
    def render
      h = Builder::XmlMarkup.new
      h.table {
        h.caption(@caption) unless @caption.nil?
        render_header(h)
        h.tfoot  
        render_body_rows(h)
      }
    end
        
  protected
    
    #
    # Create new.
    #
    def initialize(doc, rows)
      @doc = doc
      @rows = rows
      @caption = nil
      @each_cell = Hash.new
      @labels = Hash.new
      @calculated = Hash.new
      @no_headers = false
      @column_order = rows.first.keys
    end
    
    #
    # Render the <thead> of a table.
    #
    def render_header(h)
      unless @no_headers 
        h.thead {
          h.tr {
            @column_order.each { |c| h.th(@labels[c] || c.to_s.humanize) }
          }
        }
      end
    end
    
    #
    # Render the <tbody> of a table.
    #
    def render_body_rows(h)
      h.tbody {
        @rows.each do |r|
          h.tr {
            @column_order.each do |col|
              r[col.to_s] = @calculated[col].call(col, r) unless @calculated[col].nil?
              if @each_cell[col].nil?
                h.td(r[col.to_s])
              else
                h.td(@each_cell[col].call(col, r) || r[col.to_s])
              end
            end
          }
        end
      }      
    end
        
  end
  
end