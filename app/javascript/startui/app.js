console.log('before tb:load')
document.addEventListener("turbolinks:load", function() {
  console.log('tb:load')
/* ==========================================================================
    Header mobile menu
    ========================================================================== */

  if (!("ontouchstart" in document.documentElement)) {
    document.documentElement.className += " no-touch";
  }

	// Dropdowns
	$('.site-header-collapsed .dropdown').each(function(){
		var parent = $(this),
			btn = parent.find('.dropdown-toggle');

		btn.click(function(){
			if (parent.hasClass('mobile-opened')) {
				parent.removeClass('mobile-opened');
			} else {
				parent.addClass('mobile-opened');
			}
		});
	});

	$('.dropdown-more').each(function(){
		var parent = $(this),
			more = parent.find('.dropdown-more-caption'),
			classOpen = 'opened';

		more.click(function(){
			if (parent.hasClass(classOpen)) {
				parent.removeClass(classOpen);
			} else {
				parent.addClass(classOpen);
			}
		});
	});

	// Left mobile menu
	$('.hamburger').click(function(){
		if ($('body').hasClass('menu-left-opened')) {
			$(this).removeClass('is-active');
			$('body').removeClass('menu-left-opened');
			// $('html').css('overflow','auto');
		} else {
			$(this).addClass('is-active');
			$('body').addClass('menu-left-opened');
			// $('html').css('overflow','hidden');
		}
	});

	$('.mobile-menu-left-overlay').click(function(){
		$('.hamburger').removeClass('is-active');
		$('body').removeClass('menu-left-opened');
		$('html').css('overflow','auto');
	});

	// Right mobile menu
	$('.site-header .burger-right').click(function(){
		if ($('body').hasClass('menu-right-opened')) {
			$('body').removeClass('menu-right-opened');
			$('html').css('overflow','auto');
		} else {
			$('.hamburger').removeClass('is-active');
			$('body').removeClass('menu-left-opened');
			$('body').addClass('menu-right-opened');
			$('html').css('overflow','hidden');
		}
	});

	$('.mobile-menu-right-overlay').click(function(){
		$('body').removeClass('menu-right-opened');
		$('html').css('overflow','auto');
	});

/* ==========================================================================
    Side menu list
    ========================================================================== */

	$('.side-menu-list li.with-sub').each(function(){
		var parent = $(this),
			clickLink = parent.find('>span'),
			subMenu = parent.find('>ul');

		clickLink.click(function() {
			if (parent.hasClass('opened')) {
				parent.removeClass('opened');
				subMenu.slideUp();
				subMenu.find('.opened').removeClass('opened');
			} else {
				if (clickLink.parents('.with-sub').size() == 1) {
					$('.side-menu-list .opened').removeClass('opened').find('ul').slideUp();
				}
				parent.addClass('opened');
				subMenu.slideDown();
			}
		});
	});


/* ========================================================================== */

	$('.control-panel-toggle').on('click', function() {
		var self = $(this);

		if (self.hasClass('open')) {
			self.removeClass('open');
			$('.control-panel').removeClass('open');
		} else {
			self.addClass('open');
			$('.control-panel').addClass('open');
		}
	});

	$('.control-item-header .icon-toggle, .control-item-header .text').on('click', function() {
		var content = $(this).closest('li').find('.control-item-content');

		if (content.hasClass('open')) {
			content.removeClass('open');
		} else {
			$('.control-item-content.open').removeClass('open');
			content.addClass('open');
		}
	});

	$.browser = {};
	$.browser.chrome = /chrome/.test(navigator.userAgent.toLowerCase());
	$.browser.msie = /msie/.test(navigator.userAgent.toLowerCase());
	$.browser.mozilla = /firefox/.test(navigator.userAgent.toLowerCase());

	if ($.browser.chrome) {
		$('body').addClass('chrome-browser');
	} else if ($.browser.msie) {
		$('body').addClass('msie-browser');
	} else if ($.browser.mozilla) {
		$('body').addClass('mozilla-browser');
	}

	$('#show-hide-sidebar-toggle').on('click', function() {
		if (!$('body').hasClass('sidebar-hidden')) {
			$('body').addClass('sidebar-hidden');
		} else {
			$('body').removeClass('sidebar-hidden');
		}
	});
});
