module JavascriptHelper
  
  def xhr_ready(x)
    if request.xhr?
     x
    else
     content_for :closing_js, x
    end
  end
  
  def remove_spinner
    # call within rjs or other pre-existing js block only
    x = raw(%(
      jQuery('.spinner').remove();
    ))
    x
  end
  
  def highlight
    x = raw(%(
      jQuery('.notice').effect("highlight", {}, 2000, function() {
        jQuery('.notice').remove();
      });
    ))
    x
  end
  
  # ajax_flash is located in layout_helper.rb underneath notice_and_alert
  
  def application_js
    x = raw(%(
                <script type="text/javascript" charset="utf-8">
                  jQuery(function($) {
                    // remote callbacks
                    $('a[data-remote="true"]').live('ajax:beforeSend.rails', function(event) {
                      if (!$(event.target).is('.nospin')) { // if clicked link does not have a class of '.nospin'
                        $(this).html('<div class="spinner">One Second...<img alt="Spinner" src="/images/spinner2.gif" /></div>');
                      };
                    });
                    // highlight flash message on page load when it's up there
                    $('.notice').effect("highlight", {}, 3000);
                    $('.alert').effect("highlight", {}, 3000);
                    // fix an file upload error in safari on mac http://stackoverflow.com/questions/4453926/how-can-i-avoid-this-passenger-error-when-using-paperclip-in-rails
                    $('form').live('submit', function(){
                      if (/AppleWebKit|MSIE/.test(navigator.userAgent)){
                        $.ajax({url:"/ping/close", async:false});
                      }
                    });
                    #{add_to_ready_js}
                  });
                  #{add_as_function}
                </script>
              ))
    x
    # INSERT THIS AT THE BOTTOM OF layouts/application.html.haml - IT REPLACES THE NEED FOR application.js and follows the yahoo js best practices by loading js at the bottom of the page -- it also prevents the need for another request, speeding up page loading even more
    # // Example on how to use conditional callbacks, including the success callbacks
    # $('a[data-remote="true"]')
    #   .live('ajax:beforeSend.rails', function(event) {
    #     if ($(event.target).is('#donate_now_link')) {
    #       $('li#donate').hide();
    #       $('#donate_spin')
    #         .show()
    #         .html('<img alt="Spinner" src="/images/spinner2.gif" />');
    #    } else {
    #       $(this).html('<div class="spinner">One Second...<img alt="Spinner" src="/images/spinner2.gif" /></div>');
    #     };
    #   })
    #   .live('ajax:complete.rails', function(event) {
    #     if ($(event.target).is('#donate_now_link')) {
    #       $('#donate_spin').hide();
    #       $('li#donate').show();
    #     };
    #   });
  end
  
  def js_for_show_hide_within_ajax_loaded_page
    x = raw(%(
                <script type="text/javascript" charset="utf-8">
                  jQuery(function($) {
                    // click to show
                    $('.link_to_show').click(function(e) {
                      e.preventDefault();
                      $('.hidden_form').toggle();
                      $(this).toggle();
                    });
                    // click cancel button to hide
                    $('.cancel_button').click(function(e) {
                      e.preventDefault();
                      $('.hidden_form').toggle();
                      $('.link_to_show').toggle();
                    });
                  });
                </script>
              ))
    x
    # PLACE AT THE BOTTOM OF AJAX LOADED PARTIALS, SO THEY ACT ON THE DOM LOADED BY THAT PARTIAL, ONCE IT IS LOADED
    # Use this inside of pieces of a page that are loaded through ajax and thus did not exist when application.js called document ready.
    # Elements that were not present when document ready was called inside application.js cannot be acted upon by javascript and 
    # in order for them to manipulated, they need their own js. In this case the document is ready when the ajax is finished loading into the dom, and thus this needs to be placed at the bottom of the dynamically loaded partail
  end
  
  # OLD MARKDOWN
  # def wmd(preview = true)
  #   x = raw(%(
  #       <script type="text/javascript">
  #         $ = jQuery
  #         $().ready(function() {
  #             $("textarea.wmd").wmd({
  #                 "preview": #{preview},
  #                 // "helpLink": "http://daringfireball.net/projects/markdown/",
  #                 // "helpHoverTitle": "Markdown Help",
  #             });
  #         });
  #       </script>
  #   ))    
  #   xhr_ready(x)
  #   # Use the following tags as well
  #   # <div style="width: 500px;">
  #   #   <textarea class="wmd" rows="5" style="width: 100%"></textarea>
  #   # </div>
  # end
  
  def wmd(preview = 'below')
    x = raw(%(
      <script type="text/javascript">
        $ = jQuery
        $(function(){
           $('textarea.wmd').markedit({
             'preview' : '#{preview}'
           });
        });
      </script>
    ))
    xhr_ready(x)
    # for options on where to render the preview, go to https://github.com/tstone/jquery-markedit/wiki/configuration-options
    # I took this from https://github.com/tstone/jquery-markedit but i took showdown.js from https://github.com/masterbranch/wmd because it can do previewing of multiple single line breaks that outputs some text/nsome text/n some text/n  to  <br />some text<br />some text<br /> correctly, while the jquery-markedit version of showdown broke after more than one consecutive /n 
  end
  
  def ajax_wmd(preview = true)
    x = raw(%(
        <script type="text/javascript">
          $ = jQuery
          $().ready(function() {
              $("textarea.wmd").wmd({
                  "preview": #{preview},
                  // "helpLink": "http://daringfireball.net/projects/markdown/",
                  // "helpHoverTitle": "Markdown Help",
              });
          });
        </script>
    ))
    x
    # Use the following tags as well
    # <div style="width: 500px;">
    #   <textarea class="wmd" rows="5" style="width: 100%"></textarea>
    # </div>
  end
  
  def overlay
    # THIS DOES NOT CURRENTLY WORK WHEN THERE ARE :rel => 'nofollow' attributes anywhere loaded in the page
    # change the overlay trigger to something other than rel ... for the ajax one it was no sweat b/c you specify whats loaded with the href... however here I need a different approach
    x = raw(%(
            <script type="text/javascript" charset="utf-8">
              jQuery(function($) {
                $(function() {
                  $("img[rel]").overlay({effect: 'apple'});
                });
              });
            </script>
          ))
    x
    # The trigger needs to be an image that has a rel that matches the div id of the div wrapping the overlay, for example
    # HERE IS THE TRIGGER
      # <img src="http://static.flowplayer.org/tools/img/photos/gustavohouse.jpg" rel="#photo1">
    # AND HERE IS THE DIV WRAPPING THE OVERLAY
      # <div class="apple_overlay black" id="photo1" style="background-image: none; top: 43.9px; left: 363px; position: fixed; z-index: 10000; display: block; "><a class="close"></a>
      #   <img src="http://static.flowplayer.org/tools/img/photos/gustavohouse-medium.jpg">
      #   <div class="details">
      #     <h2>Berlin Gustavohouse</h2>
      #     <p>
      #       The Gustavo House in Storkower Strasse. It was built in 1978 and reconstructed in
      #       1998 by the Spanish artist Gustavo.
      #     </p>
      #   </div>
      # </div>
  end
  
  def ajax_overlay(args = {:bgc => 'white_overlay.png', :spinner => 'spinner2.gif', :color => '#000'})
  # def ajax_overlay(overlay_bgc = 'transparent_overlay.png', spinner = 'spinner.gif', style = 'color:#FFF;')
    bgc = args[:bgc]
    spinner = args[:spinner]
    color = args[:color]
    style = args[:style]
    # call this from within a main view page only(show, index, new or edit)
    # yeild this in application.html.haml but before any other closing javascript
    # DO NOT CALL THIS FROM WITHIN A COLLECTION PARTIAL -- if called within a collection partial it will be inserted into the page more than once, which will break it
    content_for :closing_js do
      # FIXME - calling the galleria inside here works but not more than once per page -- aka u really need to reload the page before you can reload another galleria within an ajax overlay otherwise the spinner just spins, safari all but freezes and the pictures are only sort of shown
      # yield this last inside application.html.haml so that when rel 'nofollow' causes an error, it doesn't break any js below it.
      raw(%(
        <div class="apple_overlay" id="overlay" style="background-image:url(/images/#{bgc}); color:#{color}; #{style}">
          <div class="contentWrap"></div>
        </div>
        <script type="text/javascript" charset="utf-8">
          jQuery(function() {
            $ = jQuery
            $(".overlay").overlay({
              mask: 'gray',
              effect: 'apple',
              top: '0.1%',
              left: 0,
              target: '#overlay',
              fixed: false,
              onBeforeLoad: function() {
                $(".apple_overlay .contentWrap").html('<div><p>One Second...</p><img alt="Spinner" src="/images/#{spinner}" /></div>');
                // grab wrapper element inside content
                var wrap = this.getOverlay().find(".contentWrap");
                // load the page specified in the trigger
                wrap.load(this.getTrigger().attr("href"));
              }
            });
          });
        </script>
      ))
    end
    # The trigger needs to be a link with a rel that matches the (empty) div id wrapping the overlay, the id for the empty div is by default, id="overlay"
    # HERE IS THE TRIGGER
      # <a href="external-content.htm" rel="#overlay">
      #   <!-- remember that you can use any element inside the trigger -->
      #   <button type="button">Show external page in overlay</button>  
      # </a>
    # AND HERE IS THE (empty) DIV WRAPPING THE OVERLAY - IT IS ADDED WITH THE HELPER METHOD
    # content is loaded externally from the href of the trigger <a></a>
      # <div class="apple_overlay" id="overlay">
      #   <a class="close"></a>
      #   <!-- the external content is loaded inside this tag -->
      #   <div class="contentWrap"></div>
      # </div>
    # FYI - you can have as many trigger <a></a> tags as you want and all have the same rel="#overlay", and only the href differs, loading different content from its source into the (empty) div id="overlay"
    # the class="apple_overlay" is for css styling only!
  end
  
  def scrollable_gallery_css(image_wrap = '850', mt = '15', mr = '15', mb = '15', ml = '15', pt = '0', pr = '0', pb = '0', pl = '0')
    # Pass this only to the parent page but not within a collection partial so it only get called once -- do not call it within the remote page itself as the css needs to exist before that page is loaded -- the js part of this (next helper method) however, gets called within the remotely loaded page instead
    # DONT FORGET TO PASS IN THE SIZE OF THE #image_wrap div which is the the size of the wrapper for the large image
    content_for :inline_css do
      raw(%(
        <style type="text/css" media="screen">
          /* styling for the image wrapper  */
          #image_wrap {
            /* dimensions */
            width:#{image_wrap}px;
            margin:#{mt}px #{mr}px #{mb}px #{ml}px;
            padding:#{pt}px #{pr}px #{pb}px #{pl}px;
            /* centered */
            text-align:center;
            /* some "skinning" */
            background-color:#efefef;
            border:2px solid #fff;
            outline:1px solid #ddd;
            -moz-ouline-radius:4px;
          }
        </style>
      ))
    end
    # HERE IS THE HTML STRUCTURE FOR THE SCROLLABLE GALLERY
    # haml code example with the in_groups_of method begins next on next line
    # #image_wrap
    #   = image_tag("/images/blank.gif", :size => '500x375')
    # #listing_photos_scrollable_gallery
    #   %a.prev.browse.left
    #   .scrollable
    #     .items
    #       - @listing_photos.in_groups_of(5, false) do |group_of_listing_photos| 
    #         %div
    #           - for listing_photo in group_of_listing_photos
    #             = image_tag(listing_photo.photo(:gallery), :title => listing_photo.title, :alt => listing_photo.alt)
    #   %a.next.browse.right
    # %button{:type => "button", :onClick => "api.play()"} Play
    # %button{:type => "button", :onClick => "api.pause()"} Pause
    # %button{:type => "button", :onClick => "api.stop()"} Stop
  end
  
  def scrollable_gallery_js(thumb = 'thumb', full = 'gallery')
    # call this within the remotely loaded partial but call the css for this (the prev helper method) within the parent page
    # DONT FORGET TO PASS IN THE PAPERCLIP STYLES
    x = raw(%(
      <script type="text/javascript" charset="utf-8">
        jQuery(function() {
          $ = jQuery
          $(".scrollable").scrollable();
          $(".items img").click(function() {
            // see if same thumb is being clicked
            if ($(this).hasClass("active")) { return; }
            // calclulate large image's URL based on the thumbnail URL (flickr specific)
            var url = $(this).attr("src").replace("/#{thumb}/", "/#{full}/");
            // get handle to element that wraps the image and make it semi-transparent
            var wrap = $("#image_wrap").fadeTo("medium", 0.5);
            // the large image from www.flickr.com
            var img = new Image();
            // call this function after it's loaded
            img.onload = function() {
              // make wrapper fully visible
              wrap.fadeTo("fast", 1);
              // change the image
              wrap.find("img").attr("src", url);
            };
            // begin loading the image from www.flickr.com
            img.src = url;
            // activate item
            $(".items img").removeClass("active");
            $(this).addClass("active");
          // when page loads simulate a "click" on the first image
          }).filter(":first").click();
        });
      </script>
    ))    
    x
  end

  def galleria_js
    # content_for :inline_js do
    #   javascript_include_tag 'galleria/galleria', 'galleria/galleria.history', :cache => "galleria/gallery"
    # end   
    # FIXME - galleria lightbox reduces size when you scoll through until it disappears, then it starts over. 
    # FIXME - CALLING THIS WITHIN AN OVERLAY MORE THAN ONCE PER PAGE RELOAD CAUSES IT TO ALMOST FREEZE SAFARI AND TO NOT DISPLAY THE IMAGES, KIND OF LIKE IT DOESN'T IN FIREFOX OR IE EVER, RIGHT NOW AT LEAST
    # I bet its a css problem and likely a 100% sizing issue or similar - or something b/c of the ridiculous number of resets I've used
    x = raw(%(
      <script type="text/javascript" charset="utf-8">  
        $ = jQuery   
        Galleria.loadTheme('/javascripts/galleria/galleria.classic.js');    
        $('#galleria').galleria({
            show_imagenav: true, // remove the prev/next arrows
            transition: 'fade', // crossfade photos
            transition_speed: 700, // slow down the crossfade
            carousel_steps: 'auto',
            // show_caption: true,
            height: '624px',
            image_crop: true,
            image_pan: true,
            // debug:true,
            // thumb_crop: false,
            // thumb_fit: false,
            extend: function() {
                var gallery = this; // save the scope
                $('#nav a').click(function(e) {
                    e.preventDefault(); // prevent default actions on the links
                })
                // attach gallery methods to links:
                $('#g_prev').click(function(e) {
                    e.preventDefault();
                    gallery.prev();
                });
                $('#g_next').click(function(e) {
                    e.preventDefault();
                    gallery.next();
                });
                $('#g_play').click(function(e) {
                    e.preventDefault();
                    gallery.play();
                });
                $('#g_pause').click(function(e) {
                    e.preventDefault();
                    gallery.pause();
                });
                $('#g_fullscreen').click(function(e) {
                    e.preventDefault();
                    gallery.enterFullscreen();
                });
                this.bind(Galleria.IMAGE, function(e) {
                    // bind a click event to the active image
                    $(e.imageTarget).css('cursor','pointer').click(this.proxy(function() {
                        // open the image in a lightbox
                        this.openLightbox();
                    }));
                });
            }
        });    
      </script>
    ))
    x
  end
  
  def faux_columns(element_class = 'columns')
    content_for :closing_js do
      raw(%(
        <script type="text/javascript" charset="utf-8">
          jQuery(function($) {
            $(".#{element_class}").equalHeights();
          });
        </script>
      ))
    end
  end
  
  def count_chars(text_area_class, max_chars, max_chars_warning)
    # put this at the bottom of the form partial that is loaded remotely.
    x = raw(%(
      <script type="text/javascript" charset="utf-8">
        jQuery(function($) {
          $('.#{text_area_class}').jqEasyCounter({
              'maxChars': #{max_chars},
              'maxCharsWarning': #{max_chars_warning},
              'msgFontSize': '12px',
              'msgFontColor': '#000',
              'msgFontFamily': 'Helvetica Neue',
              'msgTextAlign': 'left',
              'msgWarningColor': '#F00',
              'msgAppendMethod': 'insertBefore'
          });
        });
      </script>
    ))
    if request.xhr?
      x
    else
      content_for :closing_js do
        x
      end
    end
  end
  
  def tablesorter_js
    content_for :inline_js do
      javascript_include_tag 'jquery.tablesorter.min'
    end
    content_for :closing_js do
     raw(%(
      <script type="text/javascript" charset="utf-8">
        jQuery(function($) {
          // FOR TABLESORTING
            $.tablesorter.defaults.widgets = ['zebra'];
            $("table").tablesorter();
        });
      </script>
     ))
    end
  end
  
  def animated_scroll
    content_for :closing_js do
      raw(%(
        <script type="text/javascript" charset="utf-8">
          jQuery(function($) {
            // initialize scrollable together with the autoscroll plugin
            var root = $("#scroller").scrollable({circular: true, mousewheel: true}).autoscroll({ 
              autoplay: true,
              interval: 3000,
              autopause: true
            });
            // provide scrollable API for the action buttons
            window.api = root.data("scrollable");
          });
        </script>
      ))
    end
    # HERE IS THE HTML HAML THAT GOES WITH IT
    # %a.prev.browse.left
    # #scroller
    #   .items
    #     - @model.in_groups_of(5, false) do |group_of_models|
    #       %div
    #         - for model in group_of_models
    #           = link_to image_tag(model.photo(:scroll_thumbs)), model, :title => "More about #{model.name.titleize}"
    # %a.next.browse.right
    # #actionButtons
    #   /%button{:type => "button", :onClick => "api.play()"} Play
    #   /%button{:type => "button", :onClick => "api.pause()"} Pause
    #   /%button{:type => "button", :onClick => "api.stop()"} Stop
  end
  
  def scrollable_slideshow(args = {:autoplay => 'true', :clickable => 'true'})
    autoplay = args[:autoplay]
    clickable = args[:clickable]
    content_for :closing_js do
      raw(%(
        <script type="text/javascript" charset="utf-8">
          jQuery(function($) {
            // FOR THE JQUERY TOOLS UI TAB SLIDESHOW
            $(".slidetabs").tabs(".images > .each", {
              // enable "cross-fading" effect
              effect: 'fade',
              // fadeOutSpeed: "slow",
              fadeOutSpeed: #{@site.fade_out},
              fadeInSpeed:  #{@site.fade_in},
              // start from the beginning after the last tab
              rotate: true
            // use the slideshow plugin. It accepts its own configuration
            }).slideshow({
              // MY CONFIGS
              autoplay: #{autoplay},
              clickable: #{clickable},
              interval: #{@site.slideshow_interval}
            });
          });
        </script>
      ))
    end
  end
  
  def calendar_picker(field_id)
    content_for :closing_js do
      javascript_tag do
        %(
          jQuery(function($) {
            $('#{field_id}').datepicker();
          });
        )
      end
    end
  end
  
  def flowplayer(tag = '.flowplayer', swf = 'flowplayer', controls = 'flowplayer.controls')
    x = raw(%(
      <script type="text/javascript" charset="utf-8">
        jQuery(function($) {
          flowplayer('div#{tag}', '/#{swf}.swf', {
            screen: {
             // bottom: 0 // make the video take all the height
            },
            plugins: {
              controls: {
                url: '/#{controls}.swf'
                // optional, add comma to previous line before using
                // buttonColor: 'rgba(0, 0, 0, 0.9)',
                // buttonOverColor: '#000000',
                // backgroundColor: '#D7D7D7',
                // backgroundGradient: 'medium',
                // sliderColor: '#FFFFFF',
                // sliderBorder: '1px solid #808080',
                // volumeSliderColor: '#FFFFFF',
                // volumeBorder: '1px solid #808080',
                // timeColor: '#000000',
                // durationColor: '#535353'
              } 
            },
            clip: {
              // autoPlay: false
              scaling: 'orig'
            }
          });
        });
      </script>
    ))
    if request.xhr?
      x
    else
      content_for :closing_js do
        x
      end
    end
  end
  
  def image_custom_text_js
    x = raw(%(
      <script type="text/javascript" charset="utf-8">
        jQuery(function($) {
          $('.inline_checkboxes input[checked="checked"]').parent().parent().next('.custom_text_for_feature_on').show();
          $('.inline_checkboxes input[type="checkbox"]').click(function() {
            $(this).parent().parent().next('.custom_text_for_feature_on').show();
          });
        });
      </script>
    ))
    xhr_ready(x)
    # pg 217 jquery 1.3 to fix the checkboxes -- the custom text box does not currently hide when they all are unchecked
  end
  
end
