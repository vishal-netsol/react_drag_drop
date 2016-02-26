Table = FixedDataTable.Table
Column = FixedDataTable.Column
Cell = FixedDataTable.Cell

@placeholder = document.createElement("li");
placeholder.className = "placeholder";

@Home = React.createClass

  getInitialState: ->
    data: ["Red", "Green", "Blue", "Yellow", "Black", "White", "Orange"]
    data1: ["123"]
    columnWidths: {Size: 1240, UserName: 150, Email: 1000, Firstname: 70, Lastname: 70, Education: 0, Contact: 0, Col2: 0}
    tableWidth: _.sum(_.values({Size: 1240, UserName: 150, Email: 1000, Firstname: 70, Lastname: 70, Education: 0, Contact: 0, Col2: 0}))
    offset: 100
    resized_columns: []
    rows: [{Size: "L", UserName: 'VS', Email: 'v@s.com', Firstname: 'v', Lastname: 's', Education: 'PG', Contact: '000001245678', Col2: 'col2'}]

  componentDidMount: ->
    window_width = $('body').width()
    avl_width = window_width - @state.tableWidth
    offset = avl_width/(_.keys(@state.columnWidths).length + 1)
    tableWidth = (_.keys(@state.columnWidths).length + 1) * offset + @state.tableWidth
    column_width = _.sum(_.values(@state.columnWidths))
    columnWidths = @state.columnWidths
    if column_width < tableWidth
      for keys of columnWidths
        columnWidths[keys] += offset
    else
      diff = column_width - window_width
      offset = diff/(_.keys(@state.columnWidths).length + 1)
      while diff > 0
        for keys of columnWidths
          if columnWidths[keys] > offset + 10
            columnWidths[keys] -= offset
          else
            columnWidths[keys] += offset
        diff = _.sum(_.values(@state.columnWidths)) - tableWidth
    @setState tableWidth: tableWidth, columnWidths: columnWidths, offset: (offset - 1)
    
  rowGetter: (row) ->
    @state.rows[row.rowIndex][row.columnKey]

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
    @state.resized_columns.push columnKey
    columnWidths = @state.columnWidths
    diff = columnWidths[columnKey] - newColumnWidth
    columnWidths[columnKey] = newColumnWidth
    offset = diff/((_.difference(_.keys(columnWidths), @state.resized_columns)).length + 1)
    console.log("remaining keys "+ _.difference(_.keys(columnWidths) - @state.resized_columns))
    column_width = _.sum(_.values(columnWidths))
    for keys of columnWidths
      if !@state.resized_columns.includes(keys)
        columnWidths[keys] += offset
    @setState columnWidths: columnWidths, offset: @state.offset + offset

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
          width={@state.tableWidth}
          height={112}
          rowsCount={@state.rows.length}
          onColumnResizeEndCallback={@onColumnResizeEnd}
          isColumnResizing={false}>
          {for data in _.keys(@state.columnWidths)
            <Column
              key = data
              header={data}
              width={@state.columnWidths[data]}
              minWidth = {10}
              isResizable={true}
              columnKey={data}
              cell={@rowGetter}/>
          }
          <Column
            header="Name"
            width={@state.offset}
            minWidth = {10}
            columnKey="Name"/>
        </Table>
    </div>
