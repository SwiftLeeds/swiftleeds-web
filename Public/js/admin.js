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
        if (element.dataset.event.includes(selectedEvent)) {
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
    
    const endpoint = 'admin/' + trigger.data('swiftleeds-admin');
    console.log('Requesting ' + endpoint);
    
    $.ajax({
        type: "GET",
        url: endpoint,
        success: (data) => {
            modal.find('.modal-content').html(data);
            
            $("[data-swiftleeds-selectcurrentevent]").each((offset, element) => {
                const value = localStorage['selectedEvent'];
                $(element).find('option[value=' + value + ']').attr('selected', true);
            });
            
            modal.find('.needs-validation').each((offset, element) => {
                const form = $(element);
                form.on('click', '[data-swiftleeds-form]', (event) => {
                    const crudEvent = $(event.currentTarget).data('swiftleeds-form');
                    console.log('Received Form Event: ' + crudEvent);
                    
                    const isValid = element.checkValidity();
                    element.classList.add('was-validated');
                    
                    if (isValid) {
                        // POST admin/:key/create
                        // POST admin/:key/:ID/update
                        // POST admin/:key/:ID/delete
                        const crudEndpoint = 'admin/' + trigger.data('swiftleeds-admin') + '/' + crudEvent;
                        var disabled = form.find(':input:disabled').removeAttr('disabled');
                        const formData = new FormData(element);
                        const useFormData = form.attr('enctype') == 'multipart/form-data'
                        const data = useFormData ? formData : form.serialize();
                        disabled.attr('disabled','disabled');
                        
                        console.log('Requesting ' + crudEndpoint);
                        
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
