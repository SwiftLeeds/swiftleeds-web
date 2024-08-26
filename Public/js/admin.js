// Handle Event Selection
const localSelectedEvent = localStorage['selectedEvent'];

if (localSelectedEvent) {
    $("#event-select").val(localSelectedEvent).change();
}

selectedEventUpdated(false); // on load
$("#event-select").on('change', (event) => {
    selectedEventUpdated(true); // on change
});

function selectedEventUpdated(change) {
    const selectedEvent = $("#event-select").find(":selected").attr("value");
    
    if (change) {
        localStorage['selectedEvent'] = selectedEvent;
    }
    
    $("[data-event-filter] li[data-event]").each((offset, element) => {
        if (element.dataset.event.includes(selectedEvent) || element.dataset.event == '') {
            element.classList.remove('hidden');
        } else {
            element.classList.add('hidden');
        }
    });
    
    $("[data-event-filter]").each((offset, element) => {
        const list = $(element);
        const itemCount = list.find('li[data-event]').length;
        const hiddenItemCount = list.find('li[data-event].hidden').length;
        
        if (hiddenItemCount == itemCount) {
            list.find('.alert').removeClass('hidden');
        } else {
            list.find('.alert').addClass('hidden');
        }
    });
}

// Handle Dynamic Modals with Form Validation
$("[data-swiftleeds-admin]").on('click', (e) => {
    e.preventDefault();
    
    const trigger = $(event.currentTarget);
    const modal = $("#modal-admin");
    
    modal.modal('show');
    modal.find('.modal-content').html("<div class=\"modal-header\"><h5 class=\"modal-title\">Loading...</h5><button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"modal\" aria-label=\"Close\"></button></div>");
    
    const endpoint = 'admin/' + trigger.data('swiftleeds-admin')
        .replace('[FILTER_EVENT]', localStorage['selectedEvent']);
    console.log('Requesting ' + endpoint);
    
    $.ajax({
        type: "GET",
        url: endpoint,
        success: (data) => {
            modal.find('.modal-content').html(data);
            
            const dataSize = modal.find('.modal-content [data-modal-size]');
            if(dataSize.length == 1) {
                modal.find('.modal-dialog').addClass(dataSize.data('modal-size'));
            }
            
            modal.find('[data-swiftleeds-form="delete"]').each((offset, element) => {
                const popover = new bootstrap.Popover(element, {
                    title: 'Are you sure?',
                    content: 'This will permanently delete this item.',
                    trigger: 'click',
                    html: true,
                    placement: 'top',
                    container: modal,
                    customClass: 'delete-confirmation'
                });
                
                element.addEventListener('show.bs.popover', () => {
                    setTimeout(() => {
                        popover.hide();
                    }, 2000);
                })
            });
            
            $("[data-swiftleeds-selectcurrentevent]").each((offset, element) => {
                const value = localStorage['selectedEvent'];
                $(element).find('option[value=' + value + ']').attr('selected', true);
            });
            
            $("[data-swiftleeds-selectCurrentDay]").each((offset, element) => {
                const value = $("#day-select").val();
                $(element).find('option[value=' + value + ']').attr('selected', true);
            });
            
            modal.find('.needs-validation').each((offset, element) => {
                const form = $(element);
                form.on('click', '[data-swiftleeds-form]', (event) => {
                    if ($(event.currentTarget).hasClass('btn-loading')) {
                        console.log('Ignoring. Button is working.')
                        return;
                    }
                    
                    const crudEvent = $(event.currentTarget).data('swiftleeds-form');
                    console.log('Received Form Event: ' + crudEvent);
                        
                    if(crudEvent == 'delete') {
                        if ($('.popover.delete-confirmation').length == 0) {
                            // If the popover is not visible, then do not continue.
                            // This requires that you press the button twice to delete.
                            return;
                        }
                    }
                    
                    const isValid = element.checkValidity();
                    element.classList.add('was-validated');
                    
                    if (isValid) {
                        // POST admin/:key/create
                        // POST admin/:key/:ID/update
                        // POST admin/:key/:ID/delete
                        const crudEndpoint = 'admin/' + trigger.data('swiftleeds-admin').replace('[FILTER_EVENT]', localStorage['selectedEvent']) + '/' + crudEvent;
                        var disabled = form.find(':input:disabled').removeAttr('disabled');
                        const formData = new FormData(element);
                        const useFormData = form.attr('enctype') == 'multipart/form-data'
                        const data = useFormData ? formData : form.serialize();
                        disabled.attr('disabled','disabled');
                        
                        console.log('Requesting ' + crudEndpoint);
                        
                        const button = $(event.currentTarget)
                        const buttonContents = button.html();
                        button.addClass('btn-loading');
                        button.html("<span class=\"spinner-border spinner-border-sm me-2\" role=\"status\" aria-hidden=\"true\"></span>Loading...");
                        
                        $.ajax({
                            type: "POST",
                            url: crudEndpoint,
                            data: data,
                            contentType: useFormData ? false : 'application/x-www-form-urlencoded',
                            processData: !useFormData,
                            success: (data) => {
                                if (data == 'OK') {
                                    location.reload();
                                } else {
                                    console.log(data);
                                }
                            },
                            error: (req) => {
                                button.removeClass('btn-loading');
                                button.html(buttonContents);
                                
                                console.log(req);
                                if (req.responseJSON && req.responseJSON.error) {
                                    modal.find('.modal-body').prepend('<div class="alert alert-danger" role="alert"><strong>Failed</strong>: ' + req.responseJSON.reason + '</div>')
                                }
                            }
                        })
                    }
                })
            });
        },
        error: (req) => {
            console.log(req);
            if (req.responseJSON && req.responseJSON.error) {
                modal.find('.modal-title').html('Failed: ' + req.responseJSON.reason);
            }
        }
    });
});
