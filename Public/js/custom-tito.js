
window.tito =
  window.tito ||
  function() {
    (tito.q = tito.q || []).push(arguments);
  };

tito('on:registration:started', function(data){
    var titoModal = document.getElementById('modalTitoOrder');
    var modal = bootstrap.Modal.getInstance(titoModal)
    modal.hide();
    
    $(".modal-backdrop").hide();
    $("body").removeClass("modal-open");
})
