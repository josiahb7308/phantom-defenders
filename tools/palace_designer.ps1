# PALACE DESIGNER: measures and draws a track layout. Runs on your computer only (no Studio needed).
# Usage (PowerShell):   . .\palace_designer.ps1 ; Analyze-Track -Name X -Lanes "x,z;x,z;..#x,z;..." -Pools "x,z,r;..." -Pads "x,z;..." -Out "X.png"
# Coordinates are the same map-local studs the game uses: x and z from -105 to 105. A lane is a list of "x,z" waypoints separated by ";".
# Several lanes are separated by "#". The last waypoint of a lane is where shadows reach your Treasure.
# Rules used (copied from the game): towers must be 9 studs or more from the lane centre, 7 studs from each other; land towers stay 3 studs out of pools;
# pads give +25% range, aquatic towers on water give +20% range.

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Globalization;
using System.Text;

public class PtS { public double X; public double Z; public double D; public int Lane; }

public static class Designer {
	public const double Half = 105.0;
	public const double PathWidth = 10.0;
	public const double Step = 2.0;
	static List<PtS> samples;
	static List<double[]> segs;
	static List<double[]> pools;
	static List<double[]> pads;
	static List<double> laneLen;

	static double[] Parse(string s) {
		string[] a = s.Split(',');
		double[] r = new double[a.Length];
		for (int i = 0; i < a.Length; i++) r[i] = double.Parse(a[i].Trim(), CultureInfo.InvariantCulture);
		return r;
	}
	static List<double[]> ParseList(string s) {
		List<double[]> l = new List<double[]>();
		if (string.IsNullOrEmpty(s)) return l;
		foreach (string part in s.Split(';')) if (part.Trim().Length > 0) l.Add(Parse(part));
		return l;
	}
	static void Build(string lanesStr) {
		samples = new List<PtS>(); segs = new List<double[]>(); laneLen = new List<double>();
		string[] lanes = lanesStr.Split('#');
		for (int li = 0; li < lanes.Length; li++) {
			string[] pts = lanes[li].Split(';');
			double d = 0; double[] prev = null;
			for (int i = 0; i < pts.Length; i++) {
				double[] p = Parse(pts[i]);
				if (prev != null) {
					double dx = p[0] - prev[0], dz = p[1] - prev[1];
					double len = Math.Sqrt(dx * dx + dz * dz);
					segs.Add(new double[] { prev[0], prev[1], p[0], p[1], li });
					int n = (int)Math.Ceiling(len / Step);
					for (int k = 0; k < n; k++) {
						double t = (double)k / n;
						PtS s = new PtS(); s.X = prev[0] + dx * t; s.Z = prev[1] + dz * t; s.D = d + len * t; s.Lane = li;
						samples.Add(s);
					}
					d += len;
				}
				prev = p;
			}
			PtS last = new PtS(); last.X = prev[0]; last.Z = prev[1]; last.D = d; last.Lane = li;
			samples.Add(last);
			laneLen.Add(d);
		}
	}
	static double DistToSeg(double px, double pz, double[] s) {
		double ax = s[0], az = s[1], bx = s[2], bz = s[3];
		double abx = bx - ax, abz = bz - az;
		double ab2 = abx * abx + abz * abz;
		double t = ab2 < 1e-9 ? 0 : ((px - ax) * abx + (pz - az) * abz) / ab2;
		if (t < 0) t = 0; if (t > 1) t = 1;
		double cx = ax + abx * t, cz = az + abz * t;
		return Math.Sqrt((px - cx) * (px - cx) + (pz - cz) * (pz - cz));
	}
	static double DistToPath(double x, double z) {
		double best = 1e9;
		foreach (double[] s in segs) { double d = DistToSeg(x, z, s); if (d < best) best = d; }
		return best;
	}
	static bool InPool(double x, double z, double margin) {
		foreach (double[] p in pools) {
			double dx = x - p[0], dz = z - p[1], r = p[2] + margin;
			if (dx * dx + dz * dz <= r * r) return true;
		}
		return false;
	}
	static bool ValidLand(double x, double z) {
		if (Math.Abs(x) > Half || Math.Abs(z) > Half) return false;
		if (DistToPath(x, z) < PathWidth / 2 + 4) return false;
		if (InPool(x, z, 3)) return false;
		return true;
	}
	static bool ValidAquatic(double x, double z) {
		if (Math.Abs(x) > Half || Math.Abs(z) > Half) return false;
		if (DistToPath(x, z) < PathWidth / 2 + 4) return false;
		return true;
	}
	static void Expose(double x, double z, double R, out double exposure, out int passes, out int lanesHit) {
		exposure = 0; passes = 0;
		HashSet<int> set = new HashSet<int>();
		int lastLane = -1; bool inRun = false;
		double r2 = R * R;
		foreach (PtS s in samples) {
			double dx = s.X - x, dz = s.Z - z;
			if (dx * dx + dz * dz <= r2) {
				exposure += Step; set.Add(s.Lane);
				if (!inRun || s.Lane != lastLane) passes++;
				inRun = true; lastLane = s.Lane;
			} else inRun = false;
		}
		lanesHit = set.Count;
	}
	class Spot { public double X, Z, E; public int Passes, Lanes; }

	static List<Spot> Scan(double R, bool aquatic) {
		List<Spot> list = new List<Spot>();
		for (double x = -Half; x <= Half; x += 3)
			for (double z = -Half; z <= Half; z += 3) {
				if (aquatic ? !ValidAquatic(x, z) : !ValidLand(x, z)) continue;
				Spot sp = new Spot(); sp.X = x; sp.Z = z;
				Expose(x, z, R, out sp.E, out sp.Passes, out sp.Lanes);
				list.Add(sp);
			}
		return list;
	}
	static List<Spot> Clusters(List<Spot> all, int count, double sep) {
		List<Spot> sorted = new List<Spot>(all);
		sorted.Sort(delegate(Spot a, Spot b) { return b.E.CompareTo(a.E); });
		List<Spot> picked = new List<Spot>();
		foreach (Spot s in sorted) {
			bool ok = true;
			foreach (Spot p in picked) { double dx = p.X - s.X, dz = p.Z - s.Z; if (Math.Sqrt(dx * dx + dz * dz) < sep) { ok = false; break; } }
			if (ok) { picked.Add(s); if (picked.Count >= count) break; }
		}
		return picked;
	}

	// Suggests pool centres (aquatic towers, +20% range) and pad positions (+25% range) that see the most lane. Pools are chosen first.
	public static string Suggest(string lanesStr, int nPools, double poolR, int nPads) {
		Build(lanesStr);
		pools = new List<double[]>(); pads = new List<double[]>();
		List<double[]> chosenPools = new List<double[]>();
		List<Spot> pc = new List<Spot>();
		for (double x = -Half + poolR + 2; x <= Half - poolR - 2; x += 3)
			for (double z = -Half + poolR + 2; z <= Half - poolR - 2; z += 3) {
				if (DistToPath(x, z) < poolR + 8) continue;
				Spot sp = new Spot(); sp.X = x; sp.Z = z;
				Expose(x, z, 46 * 1.2, out sp.E, out sp.Passes, out sp.Lanes);
				pc.Add(sp);
			}
		pc.Sort(delegate(Spot a, Spot b) { return b.E.CompareTo(a.E); });
		foreach (Spot s in pc) {
			if (chosenPools.Count >= nPools) break;
			bool ok = true;
			foreach (double[] p in chosenPools) { double dx = p[0] - s.X, dz = p[1] - s.Z; if (Math.Sqrt(dx * dx + dz * dz) < 2 * poolR + 14) { ok = false; break; } }
			if (ok) chosenPools.Add(new double[] { s.X, s.Z, poolR });
		}
		pools = chosenPools;
		List<Spot> qc = new List<Spot>();
		for (double x = -Half + 6; x <= Half - 6; x += 3)
			for (double z = -Half + 6; z <= Half - 6; z += 3) {
				if (DistToPath(x, z) < PathWidth / 2 + 4 + 5) continue;
				if (InPool(x, z, 8)) continue;
				Spot sp = new Spot(); sp.X = x; sp.Z = z;
				Expose(x, z, 46 * 1.25, out sp.E, out sp.Passes, out sp.Lanes);
				qc.Add(sp);
			}
		qc.Sort(delegate(Spot a, Spot b) { return b.E.CompareTo(a.E); });
		List<double[]> chosenPads = new List<double[]>();
		foreach (Spot s in qc) {
			if (chosenPads.Count >= nPads) break;
			bool ok = true;
			foreach (double[] p in chosenPads) { double dx = p[0] - s.X, dz = p[1] - s.Z; if (Math.Sqrt(dx * dx + dz * dz) < 32) { ok = false; break; } }
			if (ok) chosenPads.Add(new double[] { s.X, s.Z });
		}
		StringBuilder pl = new StringBuilder(), pd = new StringBuilder();
		foreach (double[] p in chosenPools) pl.Append((pl.Length > 0 ? ";" : "") + p[0] + "," + p[1] + "," + p[2]);
		foreach (double[] p in chosenPads) pd.Append((pd.Length > 0 ? ";" : "") + p[0] + "," + p[1]);
		return pl.ToString() + "|" + pd.ToString();
	}

	public static string Analyze(string name, string lanesStr, string poolsStr, string padsStr, string outPng) {
		Build(lanesStr);
		pools = ParseList(poolsStr); pads = ParseList(padsStr);
		StringBuilder sb = new StringBuilder();
		sb.AppendLine("TRACK: " + name);
		double total = 0;
		for (int i = 0; i < laneLen.Count; i++) { sb.AppendLine("  lane " + (i + 1) + ": " + Math.Round(laneLen[i]) + " studs"); total += laneLen[i]; }
		sb.AppendLine("  lanes=" + laneLen.Count + "  pools=" + pools.Count + "  pads=" + pads.Count);
		// warnings: lane touching itself, waypoints outside the arena, pools/pads too close to a lane
		int touch = 0;
		for (int i = 0; i < samples.Count && touch < 3; i += 3) {
			PtS a = samples[i];
			if (Math.Abs(a.X) > Half || Math.Abs(a.Z) > Half) { sb.AppendLine("  WARNING: lane leaves the arena near " + Math.Round(a.X) + "," + Math.Round(a.Z)); touch++; }
		}
		int crossings = 0;
		for (int i = 0; i < samples.Count; i += 2)
			for (int j = i + 1; j < samples.Count; j += 2) {
				PtS a = samples[i], b = samples[j];
				if (a.Lane == b.Lane && Math.Abs(a.D - b.D) < 30) continue;
				double dx = a.X - b.X, dz = a.Z - b.Z;
				if (dx * dx + dz * dz < 36) { crossings++; break; }
			}
		if (crossings > 0 && laneLen.Count >= 1) sb.AppendLine("  note: " + crossings + " lane samples pass within 6 studs of a far-apart part of the track (a crossing or merge; fine if intended)");
		int pi = 0;
		foreach (double[] p in pools) { pi++; double d = DistToPath(p[0], p[1]); if (d < p[2] + PathWidth / 2 + 2) sb.AppendLine("  WARNING: pool " + pi + " overlaps a lane (" + Math.Round(d - p[2], 1) + " studs clear, needs 7)"); if (Math.Abs(p[0]) + p[2] > Half || Math.Abs(p[1]) + p[2] > Half) sb.AppendLine("  WARNING: pool " + pi + " leaves the arena"); }
		pi = 0;
		foreach (double[] p in pads) { pi++; double d = DistToPath(p[0], p[1]); if (d < PathWidth / 2 + 4 + 5) sb.AppendLine("  WARNING: pad " + pi + " is too close to a lane (" + Math.Round(d, 1) + " studs, needs 14)"); }
		int validCount = 0, cells = 0;
		for (double x = -Half; x <= Half; x += 3) for (double z = -Half; z <= Half; z += 3) { cells++; if (ValidLand(x, z)) validCount++; }
		sb.AppendLine("  buildable land: " + Math.Round(100.0 * validCount / cells) + "% of the arena");
		double[] rs = new double[] { 30, 46, 70 };
		double bestAt46 = 0;
		foreach (double R in rs) {
			List<Spot> all = Scan(R, false);
			List<Spot> cl = Clusters(all, 6, 16);
			double best = cl.Count > 0 ? cl[0].E : 0;
			int multi = 0; double bestMulti = 0;
			foreach (Spot s in all) if (s.Passes >= 2) { multi++; if (s.E > bestMulti) bestMulti = s.E; }
			sb.AppendLine("  RANGE " + R + ": best spot sees " + Math.Round(best) + " studs of lane (" + Math.Round(best / (2 * R), 2) + "x a straight road)");
			StringBuilder top = new StringBuilder();
			foreach (Spot s in cl) top.Append(Math.Round(s.E) + " ");
			sb.AppendLine("     top 6 distinct spots: " + top.ToString().Trim());
			if (cl.Count >= 3) {
				double ratio = cl[0].E / Math.Max(1, cl[2].E);
				sb.AppendLine("     dominance (best / 3rd best): " + Math.Round(ratio, 2) + (ratio > 1.35 ? "   <- one spot is much better than the rest" : "   ok"));
			}
			List<double> ex = new List<double>();
			foreach (Spot s in all) ex.Add(s.E);
			ex.Sort();
			double p50 = ex.Count > 0 ? ex[ex.Count / 2] : 0, p90 = ex.Count > 0 ? ex[(int)(ex.Count * 0.9)] : 0;
			int near = 0;
			foreach (Spot s in cl) if (s.E >= 0.85 * best) near++;
			List<Spot> bigCl = Clusters(all, 30, 16);
			int hubs = 0;
			foreach (Spot s in bigCl) if (s.E >= 0.9 * best) hubs++;
			sb.AppendLine("     typical spot sees " + Math.Round(p50) + " (median), good spots " + Math.Round(p90) + " (90th pct); best is " + Math.Round(best / Math.Max(1, p50), 2) + "x the median");
			sb.AppendLine("     strong distinct spots (within 15% of the best): " + hubs + "   <- 3 to 8 is a healthy number to choose between");
			if (R == 46) bestAt46 = best;
			if (R == 30 || R == 46) {
				pi = 0;
				foreach (double[] p in pads) { pi++; double e; int ps, ln; Expose(p[0], p[1], R * 1.25, out e, out ps, out ln); sb.AppendLine("     pad " + pi + " (" + p[0] + "," + p[1] + "): sees " + Math.Round(e) + " with the +25% range, passes=" + ps + (best > 0 ? ", " + Math.Round(100 * e / best) + "% of the best land spot" : "")); }
				pi = 0;
				foreach (double[] p in pools) { pi++; double e; int ps, ln; Expose(p[0], p[1], R * 1.2, out e, out ps, out ln); sb.AppendLine("     pool " + pi + " (" + p[0] + "," + p[1] + "): an aquatic tower sees " + Math.Round(e) + " with the +20% range, passes=" + ps + (best > 0 ? ", " + Math.Round(100 * e / best) + "% of the best land spot" : "")); }
			}
		}
		// picture
		int S = 4, W = (int)(2 * Half * S), PANEL = 560;
		Bitmap bmp = new Bitmap(W + PANEL, W);
		Graphics g = Graphics.FromImage(bmp);
		g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
		g.Clear(Color.FromArgb(18, 14, 20));
		List<Spot> heat = Scan(36, false);
		double max = 1; foreach (Spot s in heat) if (s.E > max) max = s.E;
		foreach (Spot s in heat) {
			double t = s.E / max;
			int r = (int)(30 + 200 * t), gg = (int)(30 + 120 * t * t), b = (int)(60 + 80 * (1 - t));
			using (SolidBrush br = new SolidBrush(Color.FromArgb(150, r, gg, b))) g.FillRectangle(br, (float)((s.X + Half - 1.5) * S), (float)((s.Z + Half - 1.5) * S), 3 * S, 3 * S);
		}
		foreach (double[] p in pools) {
			using (SolidBrush br = new SolidBrush(Color.FromArgb(150, 40, 150, 190))) g.FillEllipse(br, (float)((p[0] - p[2] + Half) * S), (float)((p[1] - p[2] + Half) * S), (float)(2 * p[2] * S), (float)(2 * p[2] * S));
			using (Pen pen = new Pen(Color.FromArgb(220, 110, 235, 240), 3)) g.DrawEllipse(pen, (float)((p[0] - p[2] + Half) * S), (float)((p[1] - p[2] + Half) * S), (float)(2 * p[2] * S), (float)(2 * p[2] * S));
		}
		Color[] laneCols = new Color[] { Color.FromArgb(235, 90, 90, 100), Color.FromArgb(235, 110, 95, 150), Color.FromArgb(235, 95, 130, 110) };
		for (int li = 0; li < laneLen.Count; li++) {
			List<PointF> pts = new List<PointF>();
			foreach (PtS s in samples) if (s.Lane == li) pts.Add(new PointF((float)((s.X + Half) * S), (float)((s.Z + Half) * S)));
			using (Pen pen = new Pen(laneCols[li % 3], (float)(PathWidth * S))) { pen.LineJoin = System.Drawing.Drawing2D.LineJoin.Round; pen.StartCap = System.Drawing.Drawing2D.LineCap.Round; pen.EndCap = System.Drawing.Drawing2D.LineCap.Round; g.DrawLines(pen, pts.ToArray()); }
			using (Pen pen = new Pen(Color.FromArgb(200, 255, 255, 255), 2)) { pen.DashStyle = System.Drawing.Drawing2D.DashStyle.Dash; g.DrawLines(pen, pts.ToArray()); }
			PointF a = pts[0], z2 = pts[pts.Count - 1];
			g.FillEllipse(Brushes.LimeGreen, a.X - 9, a.Y - 9, 18, 18);
			g.FillRectangle(Brushes.OrangeRed, z2.X - 10, z2.Y - 10, 20, 20);
		}
		foreach (double[] p in pads) {
			float cx = (float)((p[0] + Half) * S), cz = (float)((p[1] + Half) * S);
			g.FillEllipse(Brushes.Gold, cx - 11, cz - 11, 22, 22);
			g.DrawEllipse(Pens.White, cx - 11, cz - 11, 22, 22);
		}
		List<Spot> top5 = Clusters(Scan(46, false), 5, 16);
		Font f = new Font("Arial", 13, FontStyle.Bold);
		for (int i = 0; i < top5.Count; i++) {
			float cx = (float)((top5[i].X + Half) * S), cz = (float)((top5[i].Z + Half) * S);
			g.DrawEllipse(new Pen(Color.Red, 3), cx - 10, cz - 10, 20, 20);
			g.DrawString((i + 1).ToString(), f, Brushes.White, cx - 6, cz - 9);
		}
		g.FillRectangle(new SolidBrush(Color.FromArgb(255, 28, 22, 32)), W, 0, PANEL, W);
		Font mono = new Font("Consolas", 11, FontStyle.Regular);
		g.DrawString(sb.ToString(), mono, Brushes.White, new RectangleF(W + 10, 8, PANEL - 20, W - 40));
		g.DrawString("green = lane start, red square = your Treasure, gold = pad, cyan = pool, red rings = best 5 spots for range 46, heat = lane seen at range 36", new Font("Arial", 9), Brushes.LightGray, 8, W - 18);
		bmp.Save(outPng, ImageFormat.Png);
		g.Dispose(); bmp.Dispose();
		return sb.ToString();
	}
}
"@

function Analyze-Track {
	param([string]$Name, [string]$Lanes, [string]$Pools = "", [string]$Pads = "", [string]$Out)
	[Designer]::Analyze($Name, $Lanes, $Pools, $Pads, $Out)
}
