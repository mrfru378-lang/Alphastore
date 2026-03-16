import { lazy, Suspense } from "react";
import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AuthProvider } from "@/hooks/useAuth";
import { CartProvider } from "@/hooks/useCart";
import Index from "./pages/Index";
import { Skeleton } from "@/components/ui/skeleton";

// Lazy-load non-homepage routes to reduce initial JS bundle
const PubgLanding = lazy(() => import("./pages/PubgLanding"));
const TopUp = lazy(() => import("./pages/TopUp"));
const GrowthPack = lazy(() => import("./pages/GrowthPack"));
const GrowthPackDetail = lazy(() => import("./pages/GrowthPackDetail"));
const PrimeServices = lazy(() => import("./pages/PrimeServices"));
const Tournament = lazy(() => import("./pages/Tournament"));
const Cart = lazy(() => import("./pages/Cart"));
const Dashboard = lazy(() => import("./pages/Dashboard"));
const Admin = lazy(() => import("./pages/Admin"));
// Prefetch admin chunk on idle
if (typeof window !== 'undefined') {
  const prefetchAdmin = () => { import("./pages/Admin"); };
  if ('requestIdleCallback' in window) {
    (window as any).requestIdleCallback(prefetchAdmin);
  } else {
    setTimeout(prefetchAdmin, 3000);
  }
}
const AlphaPoints = lazy(() => import("./pages/AlphaPoints"));
const EightBallPool = lazy(() => import("./pages/EightBallPool"));
const EFootball = lazy(() => import("./pages/EFootball"));
const HonorOfKings = lazy(() => import("./pages/HonorOfKings"));
const OttService = lazy(() => import("./pages/OttService"));
const BuyNowPage = lazy(() => import("./pages/BuyNowPage"));
const PaymentSuccess = lazy(() => import("./pages/PaymentSuccess"));
const PaymentCancel = lazy(() => import("./pages/PaymentCancel"));
const NotFound = lazy(() => import("./pages/NotFound"));

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <AuthProvider>
      <CartProvider>
        <TooltipProvider>
          <Toaster />
          <Sonner />
          <BrowserRouter>
            <Suspense fallback={
              <div className="min-h-screen bg-background p-6 md:p-10 space-y-6">
                <Skeleton className="h-10 w-48" />
                <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
                  {[1,2,3,4].map(i => <Skeleton key={i} className="h-24 rounded-xl" />)}
                </div>
                <Skeleton className="h-64 rounded-xl" />
              </div>
            }>
              <Routes>
                <Route path="/" element={<Index />} />
                <Route path="/pubg" element={<PubgLanding />} />
                <Route path="/topup" element={<TopUp />} />
                <Route path="/growth-pack" element={<GrowthPack />} />
                <Route path="/growth-pack/:id" element={<GrowthPackDetail />} />
                <Route path="/prime" element={<PrimeServices />} />
                <Route path="/tournament" element={<Tournament />} />
                <Route path="/cart" element={<Cart />} />
                <Route path="/dashboard" element={<Dashboard />} />
                <Route path="/admin" element={<Admin />} />
                <Route path="/alpha-points" element={<AlphaPoints />} />
                <Route path="/8ballpool" element={<EightBallPool />} />
                <Route path="/efootball" element={<EFootball />} />
                <Route path="/honor-of-kings" element={<HonorOfKings />} />
                <Route path="/ott/:serviceId" element={<OttService />} />
                <Route path="/buy-now" element={<BuyNowPage />} />
                <Route path="/payment-success" element={<PaymentSuccess />} />
                <Route path="/payment-cancel" element={<PaymentCancel />} />
                <Route path="*" element={<NotFound />} />
              </Routes>
            </Suspense>
          </BrowserRouter>
        </TooltipProvider>
      </CartProvider>
    </AuthProvider>
  </QueryClientProvider>
);

export default App;
