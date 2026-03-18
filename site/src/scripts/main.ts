const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

const markReady = (): void => {
  document.documentElement.classList.add('is-ready');
};

markReady();

const revealNodes = document.querySelectorAll<HTMLElement>('.reveal');
if (!prefersReducedMotion && 'IntersectionObserver' in window) {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('in-view');
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.2 }
  );

  revealNodes.forEach((node) => {
    observer.observe(node);
  });
} else {
  revealNodes.forEach((node) => {
    node.classList.add('in-view');
  });
}

const demoPlayer = document.querySelector<HTMLElement>('[data-demo-player]');
const demoTrigger = demoPlayer?.querySelector<HTMLButtonElement>('[data-demo-trigger]');
const demoPosterSrc = demoPlayer?.dataset.posterSrc;
const demoVideoSrc = demoPlayer?.dataset.videoSrc;

if (demoPlayer && demoTrigger && demoVideoSrc) {
  demoTrigger.addEventListener(
    'click',
    () => {
      if (demoPlayer.dataset.active === 'true') {
        return;
      }

      demoPlayer.dataset.active = 'true';

      const video = document.createElement('video');
      video.className = 'hero-demo__video';
      video.controls = true;
      video.autoplay = true;
      video.loop = true;
      video.muted = true;
      video.playsInline = true;
      video.preload = 'auto';
      if (demoPosterSrc) {
        video.poster = demoPosterSrc;
      }
      video.width = 1280;
      video.height = 800;
      video.setAttribute('aria-label', 'VidPare product demo video');
      video.src = demoVideoSrc;

      demoTrigger.replaceWith(video);

      void video.play().catch(() => {
        video.controls = true;
      });
    },
    { once: true }
  );
}
