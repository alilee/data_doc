require 'builder'

module DataDoc
  
  #
  # Presents the results of a query in an html table.
  #
  class Present
    
    #
    # Accept display options from a block. Returns html table.
    #
    def self.present(doc, arel_or_str, &blk)
      rows = doc.connection.select_all(arel_or_str)
      p = Present.new(doc, rows)
      p.instance_eval(&blk) if block_given?
      p.render
    end
    
    #
    # Defines presentation set and order of columns.
    #
    # Not every field queried needs to be presented.
    #
    def column_order(*order)
      @column_order = order
    end
    
    #
    # Set the caption for the table
    #
    def caption(text)
      @caption = text
    end
    
    #
    # Rename the column heading text for a particular column.
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
    def each_cell(&blk) # :yields: col, row
      @each_cell = blk
    end
    
    #
    # Define a calculated column based on a block.
    #
    def calculate(col, &blk) # :yields: row
      @calculated[col] = blk
    end
    
    #
    # Generate html.
    #
    def render
      h = Builder::XmlMarkup.new
      h.table {
        h.caption(@caption) unless @caption.nil?
        h.thead {
          h.tr {
            @column_order.each { |c| h.th(@labels[c] || c.to_s.humanize) }
          }
        }
        h.tfoot
        h.tbody {
          @rows.each do |r|
            h.tr {
              if @each_cell.nil?
                @column_order.each {|col| h.td(r[col.to_s]) }
              else
                @column_order.each do |col|
                  h.td(@each_cell.call(r, col) || r[col.to_s])
                end
              end
            }
          end
        }
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
      @each_cell = nil
      @labels = Hash.new
      @calculated = Hash.new
      @column_order = rows.first.keys
    end
        
  end
  
end