// Handle Event Selection

// Handle AJAX Modals
// - Form Validation
// - API Error Handling
// - Confirmation Prompts

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
            
            modal.find('.needs-validation').each((offset, element) => {
                const form = $(element);
                console.log('Found Form', form);
                $(element).on('click', '[data-swiftleeds-form]', (event) => {
                    const crudEvent = $(event.currentTarget).data('swiftleeds-form');
                    console.log('Received Form Event: ' + crudEvent);
                    
                    const isValid = element.checkValidity();
                    element.classList.add('was-validated');
                    
                    if (isValid) {
                        // POST admin/:key/create
                        // POST admin/:key/:ID/update
                        // POST admin/:key/:ID/delete
                        const crudEndpoint = 'admin/' + trigger.data('swiftleeds-admin') + '/' + crudEvent;
                        console.log('Requesting ' + crudEndpoint);
                        
                        $.ajax({
                            type: "POST",
                            url: crudEndpoint,
                            data: form.serialize(),
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
