export default {
  async fetch(r, e, c) {
    const u = new URL(r.url), p = u.pathname.toLowerCase();

    if (p === "/") {
      const indexRes = await e.ASSETS.fetch(new Request(new URL("/index.html", r.url), r));
      if (indexRes.status === 200) {
        return new Response(indexRes.body, { headers: { "content-type": "text/html; charset=utf-8", "cache-control": "no-cache" } });
      }
    }

    const txtHeaders = { "content-type": "text/plain; charset=utf-8", "access-control-allow-origin": "*", "cache-control": "no-cache" };
    let f = null;

    if (p === "/win" || p === "/win/" || p === "/setup.ps1") { f = "/setup.ps1"; }
    else if (p === "/ubuntu" || p === "/ubuntu/" || p === "/setup.sh") { f = "/setup.sh"; }

    if (f) {
      const res = await e.ASSETS.fetch(new Request(new URL(f, r.url), r));
      if (res.status === 200) return new Response(res.body, { headers: txtHeaders });
    }

    return e.ASSETS.fetch(r);
  }
};
