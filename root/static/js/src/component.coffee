ookook.namespace "component", (component) ->
  component.namespace "newItemForm", (modalForm) ->
    modalForm.initInstance = (args...) ->
      MITHGrid.initInstance 'ookook.component.newItemForm', args..., (that, container) ->
        options = that.options
        id = $(container).attr('id')
        $(container).modal('hide')
        $("#" + id + "-cancel").click ->
          $(container).modal('hide')
        $("#" + id + "-action").click ->
          data = {}
          $(container).find('.modal-form-input').each (idx, el) ->
            el = $(el)
            elId = el.attr('id')
            elId = elId.substr(id.length + 1)
            data[elId] = el.val()
            if not $.isArray(data[elId])
              data[elId] = [ data[elId] ]
          $(container).modal('hide')
          if options.model?.create?
            options.model.create data

        $(container).on 'show', ->
          $(container).find('.modal-form-input').val("")

  component.namespace "editItemForm", (modalForm) ->
    modalForm.initInstance = (args...) ->
      MITHGrid.initInstance 'ookook.component.editItemForm', args..., (that, container) ->
        options = that.options
        id = $(container).attr('id')
        $(container).modal({ keyboard: true, show: false })
        #$(container).modal('hide')
        $("##{id}-cancel").click -> $(container).modal('hide')
        $("##{id}-action").click ->
          data = {}
          $(container).find('.modal-form-input').each (idx, el) ->
            el = $(el)
            elId = el.attr('id')
            elId = elId.substr(id.length+1)
            data[elId] = el.val()
            if not $.isArray(data[elId])
              data[elId] = [ data[elId] ]
            $(container).modal('hide')
            data.id = options.application().getMetroParent()
            if options.update?
              options.update data

        $(container).on 'show', ->
          console.log "Showing", container
          app = options.application()
          item = app.dataStore.data.getItem app.getMetroParent()
          console.log "editing", item
          #$(container).find('.modal-form-input').val("")
          $(container).find('.modal-form-input').each (idx, el) ->
            el = $(el)
            elId = el.attr('id')
            elId = elId.substr(id.length+1)
            console.log "Value for", elId
            el.val(item[elId]?[0] || "")

          if options.initForm?
            options.initForm container
