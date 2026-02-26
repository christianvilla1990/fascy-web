document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('.block-header__group').forEach(function(btn) {
    btn.addEventListener('click', function(e) {
      e.preventDefault();
      document.querySelectorAll('.block-header__group').forEach(b => b.classList.remove('block-header__group--active'));
      btn.classList.add('block-header__group--active');
      const categoriaId = btn.getAttribute('data-categoria-id');
      fetch(`/?categoria=${categoriaId}`, { headers: { 'Accept': 'text/vnd.turbo-stream.html' } })
        .then(response => response.text())
        .then(html => {
          // Reemplaza el bloque completo de productos destacados
          const tempDiv = document.createElement('div');
          tempDiv.innerHTML = html;
          const newBlock = tempDiv.querySelector('.block-products-carousel');
          const oldBlock = document.querySelector('.block-products-carousel');
          if (newBlock && oldBlock) {
            oldBlock.replaceWith(newBlock);
            // Reinicializar Owl Carousel de forma limpia
            if (window.jQuery && window.jQuery.fn && window.jQuery.fn.owlCarousel) {
              var $carousel = $(newBlock).find('.owl-carousel');
              if ($carousel.data('owl.carousel')) {
                $carousel.trigger('destroy.owl.carousel');
                $carousel.removeClass('owl-loaded owl-hidden');
                $carousel.find('.owl-stage-outer, .owl-stage, .owl-item, .owl-nav, .owl-dots').remove();
              }
              var productosCount = $carousel.find('.block-products-carousel__column').length;
              if (productosCount > 0) {
                var itemsCount = Math.min(productosCount, 4);
                $carousel.owlCarousel({
                  items: productosCount,
                  margin: 14,
                  nav: false,
                  dots: false,
                  loop: false,
                  stagePadding: 1,
                  rtl: document.body.dir === 'rtl',
                  responsive: {
                    1200: {items: productosCount, margin: 14},
                    992:  {items: productosCount, margin: 10},
                    768:  {items: Math.min(productosCount, 3), margin: 10},
                    475:  {items: Math.min(productosCount, 2), margin: 10},
                    0:    {items: 1}
                  }
                });
                // Sugerencia visual: si hay menos de 4 productos, ajustar el ancho de las columnas
                if (productosCount < 4) {
                  $carousel.find('.block-products-carousel__column').css('flex', '0 0 auto').css('width', (100/productosCount)+'%');
                }
              }
            }
          }
        });
    });
  });
});
