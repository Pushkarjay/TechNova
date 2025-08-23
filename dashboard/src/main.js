function initMap() {
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 4,
    center: {lat: 39.8283, lng: -98.5795}
  });

  const db = firebase.firestore();
  db.collection("reports").onSnapshot((snapshot) => {
    snapshot.docChanges().forEach((change) => {
      if (change.type === "added") {
        const report = change.doc.data();
        const marker = new google.maps.Marker({
          position: {lat: report.location.latitude, lng: report.location.longitude},
          map: map,
          title: report.violationType
        });
        const infowindow = new google.maps.InfoWindow({
          content: `<h3>${report.violationType}</h3><img src="${report.imageUrl}" width="200">`
        });
        marker.addListener('click', () => {
          infowindow.open(map, marker);
        });
      }
    });
  });
}
