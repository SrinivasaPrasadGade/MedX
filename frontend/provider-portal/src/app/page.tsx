"use client";

import { motion, useScroll, useTransform } from "framer-motion";
import { ArrowRight, Activity, Shield, Zap, Users, CheckCircle } from "lucide-react";
import Link from "next/link";
import { useRef } from "react";

export default function LandingPage() {
  const { scrollY } = useScroll();
  const heroOpacity = useTransform(scrollY, [0, 300], [1, 0]);
  const heroScale = useTransform(scrollY, [0, 300], [1, 0.95]);

  return (
    <div className="min-h-screen bg-[#F5F5F7] text-[#1D1D1F] overflow-x-hidden font-sans selection:bg-[#0071E3] selection:text-white">

      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 px-6 py-4 glass transition-all duration-300">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-black rounded-lg flex items-center justify-center text-white font-bold text-lg">M</div>
            <span className="text-xl font-semibold tracking-tight">MedX</span>
          </div>
          <div className="hidden md:flex items-center space-x-8">
            <NavLink href="#features">Features</NavLink>
            <NavLink href="#privacy">Privacy</NavLink>
            <NavLink href="#doctors">For Doctors</NavLink>
          </div>
          <div className="flex items-center space-x-4">
            <Link href="https://patient-app-1070962557424.us-central1.run.app" className="text-sm font-medium text-[#1D1D1F] hover:text-[#0071E3] transition-colors">
              Patient Login
            </Link>
            <Link
              href="/doctor/dashboard"
              className="text-sm font-medium text-[#1D1D1F] hover:text-[#0071E3] transition-colors"
            >
              Sign In
            </Link>
            <Link
              href="/register"
              className="px-4 py-2 bg-[#0071E3] text-white rounded-full text-sm font-medium hover:bg-[#0077ED] transition-all transform hover:scale-105 active:scale-95 shadow-lg shadow-blue-500/20"
            >
              Register Organization
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative h-screen flex flex-col items-center justify-center pt-20 overflow-hidden">
        <motion.div
          style={{ opacity: heroOpacity, scale: heroScale }}
          className="text-center z-10 max-w-4xl px-6"
        >
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, ease: "easeOut" }}
          >
            <h2 className="text-[#0071E3] font-semibold text-lg md:text-xl mb-4 tracking-wide uppercase">The Future of Healthcare</h2>
            <h1 className="text-5xl md:text-7xl lg:text-8xl font-bold tracking-tight leading-[1.05] mb-6 text-[#1D1D1F]">
              Intelligent care.<br />
              <span className="text-[#6E6E73]">Reimagined.</span>
            </h1>
            <p className="text-xl md:text-2xl text-[#424245] max-w-2xl mx-auto mb-10 leading-relaxed font-light">
              Connect hospitals, doctors, and patients in one seamless ecosystem powered by advanced AI.
            </p>

            <div className="flex flex-col sm:flex-row items-center justify-center space-y-4 sm:space-y-0 sm:space-x-4">
              <Link href="/register">
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  className="px-8 py-4 bg-[#1D1D1F] text-white rounded-full text-lg font-medium shadow-xl hover:shadow-2xl transition-all flex items-center space-x-2"
                >
                  <span>Get Started</span>
                  <ArrowRight className="w-5 h-5" />
                </motion.button>
              </Link>
              <Link href="#demos">
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  className="px-8 py-4 bg-white text-[#1D1D1F] border border-[#D2D2D7] rounded-full text-lg font-medium hover:bg-gray-50 transition-all"
                >
                  Watch Demo
                </motion.button>
              </Link>
            </div>
          </motion.div>
        </motion.div>

        {/* Ambient Background Elements */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-blue-400/20 rounded-full blur-[120px] -z-10 animate-pulse-slow" />
      </section>

      {/* Features Grid (Bento Box) */}
      <section id="features" className="py-24 px-6 bg-white">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold mb-4 text-[#1D1D1F]">Everything needing care.</h2>
            <p className="text-xl text-[#86868B]">All connected in one powerful platform.</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 auto-rows-[400px]">
            {/* Feature 1: AI Analysis */}
            <BentoCard
              className="md:col-span-2 bg-[#F5F5F7] relative overflow-hidden group"
              title="AI-Powered Insights"
              description="Real-time clinical decision support using proprietary LLMs to analyze patient records instantly."
              icon={<Zap className="w-8 h-8 text-[#0071E3]" />}
            >
              <div className="absolute right-0 bottom-0 w-3/4 h-3/4 bg-white/50 backdrop-blur-md rounded-tl-3xl shadow-xl p-6 transform translate-y-12 translate-x-12 group-hover:translate-x-6 group-hover:translate-y-6 transition-transform duration-500">
                <div className="space-y-4">
                  <div className="h-4 bg-gray-200 rounded w-3/4 animate-pulse" />
                  <div className="h-4 bg-gray-200 rounded w-1/2 animate-pulse" />
                  <div className="h-32 bg-blue-50/50 rounded-xl border border-blue-100 p-4">
                    <div className="flex items-center space-x-2 mb-2">
                      <Activity className="w-4 h-4 text-blue-500" />
                      <span className="text-xs font-semibold text-blue-600">Analysis Complete</span>
                    </div>
                    <p className="text-xs text-gray-600">Patient exhibits early signs of irregularity. Recommended follow-up in 48 hours.</p>
                  </div>
                </div>
              </div>
            </BentoCard>

            {/* Feature 2: Security */}
            <BentoCard
              className="bg-black text-white"
              title="Enterprise Security"
              description="HIPAA compliant infrastructure with end-to-end encryption for all sensitive medical data."
              icon={<Shield className="w-8 h-8 text-green-400" />}
            >
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent pointer-events-none" />
            </BentoCard>

            {/* Feature 3: Organization */}
            <BentoCard
              className="bg-white border border-[#E5E5EA]"
              title="Hospital Management"
              description="Streamlined dashboard for administrators to manage doctors, shifts, and department resources."
              icon={<Users className="w-8 h-8 text-orange-500" />}
            />

            {/* Feature 4: Doctor Portal */}
            <BentoCard
              className="md:col-span-2 bg-[#0071E3] text-white relative overflow-hidden text-center flex flex-col items-center justify-center"
              title="Designed for Doctors"
              description="A beautiful, intuitive interface that lets providers focus on patients, not paperwork."
              icon={<Activity className="w-12 h-12 text-white/90" />}
            >
              <motion.div
                className="absolute inset-0 bg-gradient-to-r from-blue-600 to-blue-500 opacity-50"
                animate={{ opacity: [0.5, 0.7, 0.5] }}
                transition={{ duration: 4, repeat: Infinity }}
              />
            </BentoCard>
          </div>
        </div>
      </section>

      {/* How it Works / Workflow */}
      <section className="py-24 px-6 bg-[#F5F5F7]">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-3xl md:text-4xl font-bold text-center mb-16">Seamless Integration</h2>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-12">
            <Step
              number="01"
              title="Register"
              description="Hospitals sign up and verify their organization identity in minutes."
            />
            <Step
              number="02"
              title="Onboard"
              description="Admins invite doctors, creating secure profiles and setting production schedules."
            />
            <Step
              number="03"
              title="Care"
              description="Doctors manage appointments and patient data through our intelligent dashboard."
            />
          </div>
        </div>
      </section>

      {/* Trust / Stats */}
      <section className="py-24 bg-white border-t border-[#E5E5EA]">
        <div className="max-w-5xl mx-auto px-6 text-center">
          <h2 className="text-3xl font-bold mb-12">Trusted by modern healthcare providers.</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 opacity-60 grayscale hover:grayscale-0 transition-all duration-500">
            {/* Placeholders for logos */}
            <div className="h-12 bg-gray-200 rounded flex items-center justify-center font-bold text-gray-400">CLINIC ONE</div>
            <div className="h-12 bg-gray-200 rounded flex items-center justify-center font-bold text-gray-400">MED CARE</div>
            <div className="h-12 bg-gray-200 rounded flex items-center justify-center font-bold text-gray-400">HEALTH+</div>
            <div className="h-12 bg-gray-200 rounded flex items-center justify-center font-bold text-gray-400">CITY HOSP</div>
          </div>
        </div>
      </section>

      {/* Final CTA */}
      <section className="py-32 px-6 bg-black text-white text-center relative overflow-hidden">
        <div className="max-w-3xl mx-auto relative z-10">
          <h2 className="text-5xl md:text-6xl font-bold mb-6 tracking-tight">Ready to modernize?</h2>
          <p className="text-xl text-gray-400 mb-10">Join the platform that's redefining medical administration.</p>
          <Link href="/register">
            <button className="px-10 py-5 bg-[#0071E3] rounded-full text-xl font-medium hover:bg-[#0077ED] transition-transform transform hover:scale-105 active:scale-95">
              Get Started Now
            </button>
          </Link>
        </div>
        {/* Background Glow */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-blue-900/30 rounded-full blur-[150px] -z-0" />
      </section>

      {/* Footer */}
      <footer className="py-12 px-6 bg-[#F5F5F7] text-sm text-[#86868B]">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center">
          <div className="mb-4 md:mb-0">
            &copy; 2026 MedX Health Platform. All rights reserved.
          </div>
          <div className="flex space-x-6">
            <a href="#" className="hover:text-[#1D1D1F]">Privacy Policy</a>
            <a href="#" className="hover:text-[#1D1D1F]">Terms of Service</a>
            <a href="#" className="hover:text-[#1D1D1F]">Support</a>
          </div>
        </div>
      </footer>
    </div>
  );
}

// Components

function NavLink({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <a
      href={href}
      className="text-sm font-medium text-[#1D1D1F] hover:text-[#0071E3] transition-colors relative group"
    >
      {children}
      <span className="absolute -bottom-1 left-0 w-0 h-0.5 bg-[#0071E3] transition-all group-hover:w-full" />
    </a>
  );
}

function BentoCard({ className, title, description, icon, children }: any) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-50px" }}
      transition={{ duration: 0.5 }}
      whileHover={{ y: -5 }}
      className={`rounded-[2rem] p-8 flex flex-col justify-between shadow-sm hover:shadow-xl transition-all duration-300 ${className}`}
    >
      <div className="relative z-10">
        <div className="mb-4">{icon}</div>
        <h3 className="text-2xl font-bold mb-2">{title}</h3>
        <p className={`text-lg leading-relaxed ${className.includes("text-white") ? "text-gray-300" : "text-[#86868B]"}`}>{description}</p>
      </div>
      {children}
    </motion.div>
  );
}

function Step({ number, title, description }: any) {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9 }}
      whileInView={{ opacity: 1, scale: 1 }}
      className="flex flex-col items-center text-center p-6"
    >
      <div className="w-16 h-16 rounded-2xl bg-white shadow-lg flex items-center justify-center text-xl font-bold text-[#0071E3] mb-6 border border-gray-100">
        {number}
      </div>
      <h3 className="text-2xl font-bold mb-3">{title}</h3>
      <p className="text-[#86868B] leading-relaxed">{description}</p>
    </motion.div>
  );
}
