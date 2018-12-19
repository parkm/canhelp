let apiGet = (url) => {
  let csrfToken = document.querySelector('meta[name="csrf-token"]').content;
  return fetch('/api/internal/'+url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken,
    },
    credentials: 'include'
  }).then(r => r.json());
}

let apiPost = (url, body) => {
  let csrfToken = document.querySelector('meta[name="csrf-token"]').content;
  return fetch('/api/internal/'+url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken,
    },
    body: JSON.stringify(body),
    credentials: 'include'
  })
}

export {apiGet, apiPost};
