Table = FixedDataTable.Table
Column = FixedDataTable.Column
Cell = FixedDataTable.Cell

@placeholder = document.createElement("li");
placeholder.className = "placeholder";

@Home = React.createClass

  getInitialState: ->
    data: ["Red", "Green", "Blue", "Yellow", "Black", "White", "Orange"]
    data1: ["123"]
    columnWidths: {Recipe: 240, Size: 150}
    tableWidth: _.sum(_.values({Recipe: 240, Size: 150}))

  dragStart: (e) ->
    @dragged = e.currentTarget
    e.dataTransfer.effectAllowed = 'move'
    # Firefox requires calling dataTransfer.setData
    # for the drag to properly work
    e.dataTransfer.setData 'text/html', e.currentTarget
    return

  dragEnd: (e) ->
    @dragged.style.display = 'block'
    #@dragged.parentNode.removeChild placeholder
    @over.parentNode.removeChild placeholder
    # Update state
    data = @state.data
    data1 = @state.data1
    from = Number(@dragged.dataset.id)
    to = Number(@over.dataset.id)
    if from < to
      to--
    if @nodePlacement == 'after'
      to++
    if this.dragged.parentNode.dataset.section == "section1"
      item = data.splice(from, 1)[0]
      if this.over.parentNode.dataset.section == "section1"
        data.splice to, 0, item
      else
        data1.splice to, 0, item
    else
      item = data1.splice(from, 1)[0]
      if this.over.parentNode.dataset.section == "section2"
        data1.splice to, 0, item
      else
        data.splice to, 0, item
    @setState data: data, data1: data1
    return

  dragOver: (e) ->
    e.preventDefault()
    @dragged.style.display = 'none'
    if e.target.className == 'placeholder' || e.target.localName != 'li'
      return
    @over = e.target
    relY = e.pageY - ($(@over).offset().top)
    height = @over.offsetHeight / 2
    parent = e.target.parentNode
    if relY > height
      @nodePlacement = 'after'
      parent.insertBefore placeholder, e.target.nextElementSibling
    else if relY < height
      @nodePlacement = 'before'
      parent.insertBefore placeholder, e.target

  removeElement: (color, index, e)->
    data = @state.data
    data1 = @state.data1
    if index >= 0
      data1.splice(index, 1)
      data.push(color)
    @setState data: data, data1: data1

  onColumnResizeEnd: (newColumnWidth, columnKey) ->
    columnWidths = @state.columnWidths
    columnWidths[columnKey] = newColumnWidth
    @setState columnWidths: columnWidths

  render: ->
    <div className="container">
      <div className="section1">
        <span>Section 1</span>
        <ul onDragOver={@dragOver} data-section="section1">
          {@state.data.map(((color, i) ->
            <li key={i} data-id={i} draggable="true" onDragEnd={@dragEnd} onDragStart={@dragStart}>
              {i} {color}
            </li>
          ).bind(this))}
        </ul>
      </div>
      <div><br/></div>
      <div className="section2">
        <span>Section 2</span>
        <ul onDragOver={@dragOver} data-section="section2">
          {@state.data1.map(((color, i) ->
            <li key={i} data-id={i} draggable="true" onDragEnd={@dragEnd} onDragStart={@dragStart}>
                {i} {color}
                {if color != "123"
                  <span style={{marginLeft:"10px"; cursor:'pointer'}} onClick={@removeElement.bind(this, color, i)}>X</span>
                }
            </li>
          ).bind(this))}
        </ul>
      </div>
       <Table
          rowHeight={30}
          headerHeight={50}
          width={1000}
          height={500}
          rowsCount={2}
          onColumnResizeEndCallback={@onColumnResizeEnd}
          isColumnResizing={false}>
          <Column
            cell="recipe"
            header="Recipe"
            width={@state.columnWidths.Recipe}
            isResizable={true}
            columnKey="Recipe"/>
          <Column
            cell="size"
            header="Size"
            width={@state.columnWidths.Size}
            isResizable={true}
            columnKey="Size"/>
          <Column
            cell="name"
            header="Name"
            width={if @state.columnWidths.Name then @state.columnWidths.Name else 100}
            isResizable={true}
            columnKey="Name"/>
          <Column
            cell="email"
            header="Email"
            width={if @state.columnWidths.Email then @state.columnWidths.Email else 100}
            isResizable={true}
            columnKey="Email"/>
        </Table>
    </div>
