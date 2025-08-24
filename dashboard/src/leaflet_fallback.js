// Leaflet-based fallback renderer for the dashboard when no Google Maps/Firebase
// config is available. It reads sample_data/reports.json and renders markers,
// filter, counts, and simple authorized/unauthorized actions (client-only).

(function() {
  function initLeaflet() {
  var map = L.map('map').setView([22.3511148, 78.6677428], 5);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '© OpenStreetMap'
    }).addTo(map);

    var markers = {};
    var currentFilter = 'all';

    function updateCounts(items) {
      var counts = { all: 0, authorized: 0, unauthorized: 0 };
      items.forEach(function(r) {
        counts.all += 1;
        if (r.status === 'authorized') counts.authorized += 1;
        if (r.status === 'unauthorized') counts.unauthorized += 1;
      });
      document.getElementById('counts').textContent = 'All: ' + counts.all + '  |  Unauthorized: ' + counts.unauthorized + '  |  Authorized: ' + counts.authorized;
    }

    function shouldShow(r) {
      if (currentFilter === 'all') return true;
      return r.status === currentFilter;
    }

    function renderMarker(r) {
      var id = r.id || ('local-' + Math.random().toString(36).substr(2, 9));
      if (markers[id]) {
        map.removeLayer(markers[id]);
        delete markers[id];
      }
      var m = L.marker([r.location ? r.location.latitude : r.lat, r.location ? r.location.longitude : r.lng]);
      var content = '<div><h3>' + (r.violationType || 'Report') + '</h3>' +
                    '<p>AI Suggestion: ' + (r.aiSuggestion || '') + '</p>' +
                    '<img src="' + (r.imageUrl || r.imagePath || '') + '" width="200"/>' +
                    '<div style="margin-top:8px">' +
                    '<button onclick="window.__mark(\'' + id + '\', \'' + 'authorized' + '\')">Mark authorized</button>' +
                    '<button onclick="window.__mark(\'' + id + '\', \'' + 'unauthorized' + '\')">Mark unauthorized</button>' +
                    '</div></div>';
      m.bindPopup(content);
      if (shouldShow(r)) m.addTo(map);
      markers[id] = m;
    }

    window.__mark = function(id, status) {
      alert('Demo: would mark ' + id + ' as ' + status);
    };

    // Load data and render
    fetch('sample_data/reports.json').then(function(resp) { return resp.json(); }).then(function(data) {
      updateCounts(data);
      data.forEach(function(r) { renderMarker(r); });

      document.getElementById('filter').addEventListener('change', function(e) {
        currentFilter = e.target.value;
        Object.keys(markers).forEach(function(k) { map.removeLayer(markers[k]); delete markers[k]; });
        data.forEach(function(r) { if (shouldShow(r)) renderMarker(r); });
      });

      document.getElementById('refresh').addEventListener('click', function() {
        Object.keys(markers).forEach(function(k) { map.removeLayer(markers[k]); delete markers[k]; });
        data.forEach(function(r) { renderMarker(r); });
        updateCounts(data);
      });
    }).catch(function(err) {
      console.error('Failed to load sample data for Leaflet fallback', err);
    });
  }

  // Wait for DOM
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initLeaflet);
  } else {
    initLeaflet();
  }
})();
