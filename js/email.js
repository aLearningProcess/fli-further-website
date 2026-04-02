/**
 * ConvertKit (Kit) email opt-in integration
 *
 * SETUP — fill in these two values after creating your ConvertKit account:
 *   1. Log in at app.kit.com
 *   2. Create a form (Forms → New Form → Inline)
 *   3. Copy the Form ID from the form's URL or Settings tab
 *   4. Get your Public API Key: Account Settings → API Keys → Copy the "Public API key"
 *
 * These two values are the only things that need to change before email collection is live.
 */
var CONVERTKIT_PUBLIC_API_KEY = 'REPLACE_WITH_YOUR_CONVERTKIT_PUBLIC_API_KEY';
var CONVERTKIT_FORM_ID        = 'REPLACE_WITH_YOUR_CONVERTKIT_FORM_ID';

/**
 * Subscribe a user to the ConvertKit form.
 * @param {string} email - required
 * @param {string} [firstName] - optional but recommended
 * @returns {Promise}
 */
function subscribeToConvertKit(email, firstName) {
  var url = 'https://api.convertkit.com/v3/forms/' + CONVERTKIT_FORM_ID + '/subscribe';
  var payload = {
    api_key: CONVERTKIT_PUBLIC_API_KEY,
    email: email
  };
  if (firstName) {
    payload.first_name = firstName;
  }
  return fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    body: JSON.stringify(payload)
  }).then(function(res) {
    return res.json().then(function(data) {
      if (!res.ok) {
        throw new Error(data.message || 'Subscription failed');
      }
      return data;
    });
  });
}

/**
 * Wire up a form element for ConvertKit opt-in.
 * Looks for inputs named "email" and optionally "first_name" or "fname".
 *
 * @param {HTMLFormElement} form
 * @param {HTMLElement} [successEl] - element to show on success (hidden by default)
 * @param {HTMLElement} [errorEl]   - element to show on error (hidden by default)
 */
function wireOptInForm(form, successEl, errorEl) {
  if (!form) return;

  form.addEventListener('submit', function(e) {
    e.preventDefault();

    var emailInput = form.querySelector('[type="email"]');
    var fnameInput = form.querySelector('[name="fname"], [name="first_name"]');

    if (!emailInput || !emailInput.value) return;

    var email     = emailInput.value.trim();
    var firstName = fnameInput ? fnameInput.value.trim() : '';

    var btn = form.querySelector('[type="submit"]');
    var originalText = btn ? btn.textContent : '';
    if (btn) {
      btn.textContent = 'Sending…';
      btn.disabled = true;
    }

    subscribeToConvertKit(email, firstName)
      .then(function() {
        form.style.display = 'none';
        if (successEl) {
          successEl.style.display = '';
          successEl.removeAttribute('hidden');
        }
      })
      .catch(function(err) {
        if (errorEl) {
          errorEl.style.display = '';
          errorEl.removeAttribute('hidden');
          var msg = errorEl.querySelector('.error-message');
          if (msg) msg.textContent = err.message || 'Something went wrong. Please try again.';
        }
        if (btn) {
          btn.textContent = originalText;
          btn.disabled = false;
        }
        console.error('ConvertKit subscription error:', err);
      });
  });
}

// Auto-wire all forms with data-ck-form attribute on DOMContentLoaded
document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('[data-ck-form]').forEach(function(form) {
    var successEl = document.querySelector('[data-ck-success="' + form.id + '"]');
    var errorEl   = document.querySelector('[data-ck-error="' + form.id + '"]');
    wireOptInForm(form, successEl, errorEl);
  });
});
