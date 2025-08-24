function initMap() {
  try { if (typeof _mapReady === 'function') _mapReady(); } catch(e){}
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 5,
    center: {lat: 22.3511148, lng: 78.6677428} // center of India
  });
  const markers = {};
  let currentFilter = 'all';

  function updateCounts(items) {
    const counts = { all: 0, authorized: 0, unauthorized: 0 };
    items.forEach(r => {
      counts.all += 1;
      if (r.status === 'authorized') counts.authorized += 1;
      if (r.status === 'unauthorized') counts.unauthorized += 1;
    });
    document.getElementById('counts').textContent = `All: ${counts.all}  |  Unauthorized: ${counts.unauthorized}  |  Authorized: ${counts.authorized}`;
  }

  function shouldShow(r) {
    if (currentFilter === 'all') return true;
    return r.status === currentFilter;
  }

  function renderMarker(docLike) {
    // docLike may be a Firestore doc (with .data()) or a plain object
    const report = (typeof docLike.data === 'function') ? docLike.data() : docLike;
    const id = (typeof docLike.id !== 'undefined') ? docLike.id : (report.id || ('local-' + Math.random().toString(36).substr(2, 9)));
    if (markers[id]) {
      markers[id].setMap(null);
      delete markers[id];
    }
    const marker = new google.maps.Marker({
      position: {lat: report.location.latitude, lng: report.location.longitude},
      map: shouldShow(report) ? map : null,
      title: report.violationType
    });

    const infowindow = new google.maps.InfoWindow();
    const content = document.createElement('div');
    const title = document.createElement('h3');
    title.textContent = report.violationType;
    const p = document.createElement('p');
    p.textContent = `AI Suggestion: ${report.aiSuggestion}`;
    const img = document.createElement('img');
    img.src = report.imageUrl;
    img.width = 200;

    const btnAuth = document.createElement('button');
    btnAuth.textContent = 'Mark authorized';
    btnAuth.style.marginRight = '8px';
    btnAuth.onclick = () => {
      if (typeof firebase !== 'undefined' && firebase.firestore) {
        const db = firebase.firestore();
        db.collection('reports').doc(id).update({status: 'authorized'}).then(()=>{
          alert('Marked authorized');
        }).catch(err=>{alert('Update failed: '+err)});
      } else {
        alert('Demo: would mark authorized (no Firestore configured)');
      }
    };

    const btnUnauth = document.createElement('button');
    btnUnauth.textContent = 'Mark unauthorized';
    btnUnauth.onclick = () => {
      if (typeof firebase !== 'undefined' && firebase.firestore) {
        const db = firebase.firestore();
        db.collection('reports').doc(id).update({status: 'unauthorized'}).then(()=>{
          alert('Marked unauthorized');
        }).catch(err=>{alert('Update failed: '+err)});
      } else {
        alert('Demo: would mark unauthorized (no Firestore configured)');
      }
    };

    content.appendChild(title);
    content.appendChild(p);
    content.appendChild(img);
    content.appendChild(document.createElement('br'));
    content.appendChild(btnAuth);
    content.appendChild(btnUnauth);

    infowindow.setContent(content);
    marker.addListener('click', () => {
      infowindow.open(map, marker);
    });

    markers[id] = marker;
  }

  function refreshAll(items) {
    items.forEach(i => renderMarker(i));
  }

  function applyFilter() {
    Object.keys(markers).forEach(id => {
      const marker = markers[id];
      if (typeof firebase !== 'undefined' && firebase.firestore) {
        const db = firebase.firestore();
        db.collection('reports').doc(id).get().then(d => {
          const r = d.data();
          if (shouldShow(r)) marker.setMap(map); else marker.setMap(null);
        }).catch(_=>{
          // if fetch fails, leave marker visibility based on existing data
        });
      }
    });
  }

  // Try to use Firestore; if not available or fails, load local sample JSON
  if (typeof firebase !== 'undefined' && firebase.firestore) {
    try {
      const db = firebase.firestore();
      const query = db.collection('reports');
      query.onSnapshot((snapshot) => {
        const docs = snapshot.docs.map(d=>({ id: d.id, ...d.data() }));
        updateCounts(docs);
        Object.values(markers).forEach(m => m.setMap(null));
        Object.keys(markers).forEach(k => delete markers[k]);
        refreshAll(snapshot.docs);
      });

      document.getElementById('filter').addEventListener('change', (e) => {
        currentFilter = e.target.value;
        applyFilter();
      });

      document.getElementById('refresh').addEventListener('click', () => {
        db.collection('reports').get().then(snapshot => {
          const docs = snapshot.docs.map(d=>({ id: d.id, ...d.data() }));
          updateCounts(docs);
          Object.values(markers).forEach(m => m.setMap(null));
          Object.keys(markers).forEach(k => delete markers[k]);
          refreshAll(snapshot.docs);
        }).catch(err=>{
          console.error('Refresh failed:', err);
        });
      });
      return;
    } catch (e) {
      console.warn('Firestore present but failed, falling back to sample', e);
    }
  }

  // Fallback: load local sample JSON
  fetch('sample_data/reports.json').then(r=>r.json()).then(data => {
    updateCounts(data);
    refreshAll(data);
    document.getElementById('filter').addEventListener('change', (e) => {
      currentFilter = e.target.value;
      // re-render by clearing and re-adding markers
      Object.values(markers).forEach(m => m.setMap(null));
      Object.keys(markers).forEach(k => delete markers[k]);
      refreshAll(data);
    });

    document.getElementById('refresh').addEventListener('click', () => {
      Object.values(markers).forEach(m => m.setMap(null));
      Object.keys(markers).forEach(k => delete markers[k]);
      refreshAll(data);
    });
  }).catch(err=>{
    console.error('Failed to load sample dashboard data', err);
  });
}
