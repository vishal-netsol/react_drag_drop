@placeholder = document.createElement("li");
placeholder.className = "placeholder";

@Home = React.createClass

  getInitialState: ->
    data: ["Red", "Green", "Blue", "Yellow", "Black", "White", "Orange", ""]

  dragStart: (e) ->
    @dragged = e.currentTarget
    e.dataTransfer.effectAllowed = 'move'
    # Firefox requires calling dataTransfer.setData
    # for the drag to properly work
    e.dataTransfer.setData 'text/html', e.currentTarget
    return

  dragEnd: (e) ->
    @dragged.style.display = 'block'
    @dragged.parentNode.removeChild placeholder
    # Update state
    data = @state.data
    from = Number(@dragged.dataset.id)
    to = Number(@over.dataset.id)
    if from < to
      to--
    data.splice to, 0, data.splice(from, 1)[0]
    @setState data: data
    return

  dragOver: (e) ->
    e.preventDefault()
    @dragged.style.display = 'none'
    if e.target.className == 'placeholder' || e.target.localName != 'li'
      return
    @over = e.target
    e.target.parentNode.insertBefore placeholder, e.target
    return

  render: ->
    <ul onDragOver={@dragOver}>
      {@state.data.map(((color, i) ->
        <li key={i} data-id={i} draggable="true" onDragEnd={@dragEnd} onDragStart={@dragStart}>
          {if color
            "#{i} #{color}"
          }
        </li>
      ).bind(this))}
    </ul>
