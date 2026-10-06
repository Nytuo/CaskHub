const demo = document.querySelector('video.app-shot');
const motionPreference = matchMedia('(prefers-reduced-motion: reduce)');

if (demo) {
  const respectMotionPreference = () => {
    if (motionPreference.matches) demo.pause();
    else demo.play().catch(() => {});
  };
  motionPreference.addEventListener('change', respectMotionPreference);
  respectMotionPreference();
}

fetch('https://api.github.com/repos/alielsokary/CaskHub')
  .then(response => response.ok ? response.json() : Promise.reject(response.status))
  .then(({ stargazers_count: count }) => {
    if (!Number.isFinite(count)) return;
    document.getElementById('gh-stars').textContent =
      new Intl.NumberFormat('en', { notation: 'compact', maximumFractionDigits: 1 }).format(count).toLowerCase() + '+';
    document.getElementById('gh-star').setAttribute('aria-label', `CaskHub on GitHub, ${count.toLocaleString('en')} stars`);
  })
  .catch(() => {});

const copyButton = document.getElementById('copy');
let copyFeedbackTimer;
copyButton.addEventListener('click', async () => {
  const status = document.getElementById('copy-status');
  try {
    await navigator.clipboard.writeText(document.getElementById('brew-cmd').textContent);
    clearTimeout(copyFeedbackTimer);
    copyButton.classList.add('copied');
    copyButton.setAttribute('aria-label', 'Install command copied');
    status.textContent = 'Install command copied.';
    copyFeedbackTimer = setTimeout(() => {
      copyButton.classList.remove('copied');
      copyButton.setAttribute('aria-label', 'Copy install command');
      status.textContent = '';
    }, 1800);
  } catch {
    const range = document.createRange();
    range.selectNodeContents(document.getElementById('brew-cmd'));
    const selection = getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    status.textContent = 'Select and copy the highlighted install command.';
  }
});

let screenshotMode = 'dark';
const designNames = { standard: 'Standard', classic: 'Classic' };
const screenshotSources = {
  standard: { light: 'assets/standard-light.png', dark: 'assets/standard-dark.png' },
  classic: { light: 'assets/classic-light.png', dark: 'assets/classic-dark.png' }
};
const modeButtons = document.querySelectorAll('button[data-mode]');
const appearanceControl = document.querySelector('.segmented');
const screenshotGallery = document.querySelector('.themes');
let screenshotRequest = 0;
const selectModeControl = mode => {
  appearanceControl.dataset.mode = mode;
  modeButtons.forEach(option => option.setAttribute('aria-pressed', String(option.dataset.mode === mode)));
};
modeButtons.forEach(button => {
  button.addEventListener('click', async () => {
    const mode = button.dataset.mode;
    const request = ++screenshotRequest;
    selectModeControl(mode);
    screenshotGallery.setAttribute('aria-busy', 'true');
    const incoming = [...screenshotGallery.querySelectorAll(`[data-screenshot-mode="${mode}"]`)];
    try {
      // Decode both designs before the crossfade so a slow image never flashes blank.
      await Promise.all(incoming.map(screenshot => screenshot.decode()));
    } catch {
      if (request !== screenshotRequest) return;
      selectModeControl(screenshotMode);
      screenshotGallery.setAttribute('aria-busy', 'false');
      document.getElementById('appearance-status').textContent = 'Unable to load this appearance. Please try again.';
      return;
    }
    if (request !== screenshotRequest) return;
    screenshotMode = mode;
    screenshotGallery.querySelectorAll('[data-screenshot-mode]').forEach(screenshot => {
      const visible = screenshot.dataset.screenshotMode === mode;
      screenshot.classList.toggle('is-visible', visible);
      screenshot.setAttribute('aria-hidden', String(!visible));
    });
    screenshotGallery.querySelectorAll('[data-design]').forEach(target => {
      target.setAttribute('aria-label', `Enlarge ${designNames[target.dataset.design]} ${mode} screenshot`);
    });
    screenshotGallery.setAttribute('aria-busy', 'false');
    document.getElementById('appearance-status').textContent = `Showing both designs in ${screenshotMode} mode.`;
  });
});

const screenshotDialog = document.getElementById('screenshot-dialog');
document.querySelectorAll('[data-design]').forEach(button => {
  button.addEventListener('click', () => {
    const design = button.dataset.design;
    const screenshot = document.getElementById('expanded-screenshot');
    screenshot.src = screenshotSources[design][screenshotMode];
    screenshot.alt = `CaskHub ${designNames[design]} design in ${screenshotMode} mode`;
    document.getElementById('screenshot-title').textContent =
      `CaskHub ${designNames[design]} · ${screenshotMode === 'dark' ? 'Dark' : 'Light'}`;
    screenshotDialog.showModal();
    document.body.style.overflow = 'hidden';
  });
});
screenshotDialog.querySelector('.dialog-close').addEventListener('click', () => screenshotDialog.close());
screenshotDialog.addEventListener('close', () => { document.body.style.overflow = ''; });
screenshotDialog.addEventListener('click', event => {
  const bounds = screenshotDialog.getBoundingClientRect();
  if (event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom) {
    screenshotDialog.close();
  }
});
