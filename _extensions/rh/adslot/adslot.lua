-- {{< adslot ID >}}
-- Renders a placeholder box marking a reserved ad location. ID is used as
-- an id/data attribute so a real ad network can target the slot later.
return {
  ['adslot'] = function(args, kwargs, meta)
    local slot = args[1] and pandoc.utils.stringify(args[1]) or "generic"
    local html = '<div class="ad-slot" id="ad-slot-' .. slot ..
      '" data-ad-slot="' .. slot ..
      '"><span class="ad-slot-label">Ad space</span></div>'
    return pandoc.RawBlock('html', html)
  end
}
