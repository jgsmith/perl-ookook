ookook.namespace "component", (component) ->
  component.namespace "modalForm", (modalForm) ->
    modalForm.initInstance = (args...) ->
      MITHGrid.initInstance 'ookook.component.modalForm', args..., (that, container) ->
        options = that.options
        id = $(container).attr('id')
        $(container).modal({ keyboard: true, show: false })
        $("##{id}-cancel").click -> $(container).modal('hide')
        $("##{id}-action").click that.events.onAction.fire

  component.namespace "newItemForm", (modalForm) ->
    modalForm.initInstance = (args...) ->
      component.modalForm.initInstance 'ookook.component.newItemForm', args..., (that, container) ->
        options = that.options
        that.events.onAction.addListener ->
          id = $(container).attr('id')
          data = {}
          $(container).find('.modal-form-input').each (idx, el) ->
            el = $(el)
            elId = el.attr('id')
            elId = elId.substr(id.length + 1)
            data[elId] = el.val()
            if not $.isArray(data[elId])
              data[elId] = [ data[elId] ]
          $(container).modal('hide')
          # we need a way of figuring out parent item relationships
          # such as 'page_id' 
          if options.addParentInfo?
            data = $.extend({}, true, data, options.addParentInfo data)
          if options.model?.create?
            options.model.create data

        $(container).on 'show', ->
          app = options.application()
          $(container).find('.modal-form-input').val("")
          $(container).find('select.modal-form-input').each (idx, el) ->
            selectType = $(el).data 'select-type'
            console.log "select type:", selectType
            if selectType?
              $(el).empty()
              # walk through each item of this type and put it here
              types = MITHGrid.Data.Set.initInstance [ selectType ]
              ids = app.dataStore.data.getSubjectsUnion(types, "restType").items()
              console.log "ids:", ids
              for id in ids
                item = app.dataStore.data.getItem id
                op = $("<option></option>")
                op.attr
                  value: id
                op.text item.title[0]
                $(el).append(op)

  component.namespace "editItemForm", (modalForm) ->
    modalForm.initInstance = (args...) ->
      component.modalForm.initInstance 'ookook.component.editItemForm', args..., (that, container) ->
        options = that.options
        id = $(container).attr('id')
        that.events.onAction.addListener ->
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
            if options.addParentInfo?
              data = $.extend({}, true, data, options.addParentInfo data)
            if options.update?
              options.update data

        $(container).on 'show', ->
          app = options.application()
          item = app.dataStore.data.getItem app.getMetroParent()
          #$(container).find('.modal-form-input').val("")
          $(container).find('.modal-form-input').each (idx, el) ->
            el = $(el)
            elId = el.attr('id')
            elId = elId.substr(id.length+1)
            el.val(item[elId]?[0] || "")

          if options.initForm?
            options.initForm container
